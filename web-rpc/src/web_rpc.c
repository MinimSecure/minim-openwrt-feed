// (c) Minim Inc 2022

// This code runs as a cgi script to implement a very limited subset
// of the luci-mod-rpc functionality (as described at
// https://floatingoctothorpe.uk/2017/managing-openwrt-remotely-with-curl.html)

// Some limitations for simplicty and security
//   it only implements the auth and uci endpoints
//   it is limited to three part uci parameters eg. network.wan.proto
//   it is limited to network uci parameters ie. network.*.*
//   it is limited to parameters of minimum length 3 ie. abc.def.ghi
//   all set operations are committed immediately, commit itself does
//     nothing and all commit operations return success
//   lots of assumptions about format and whitespace are made in the
//     input parser, it is not a json parser

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>
#include <pwd.h>
#include <time.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/random.h>
#include <sys/stat.h>

#include "minim_common.h"

#ifndef TEST
#    include <uci.h>
#endif


static const char* regex_alphanumeric_str = "^[a-zA-Z0-9]*$";
static const char* regex_url_str = "^[a-zA-Z0-9:/_\?=-]*$";
static const char* regex_uci_param_str = "^[a-z0-9.:/_-]*$";

#define SECRET_FILENAME "/tmp/web_rpc_secret.txt"
#define SECRET_LENGTH 16
#define SECRET_STR_LENGTH (SECRET_LENGTH*2+1)
#define SECRET_EXPIRY_S (5*60)

// example str password is taken from mfg spec
#define MAX_PASSWORD_EXAMPLE "WoodenHammer888"

// minimum length would be abc","def","hij
#define UCI_PARAM_MINIMUM_LENGTH 3
#define UCI_PARAMS_MINIMUM_LENGTH 3*UCI_PARAM_MINIMUM_LENGTH+3*2

// generate a new authentication secret and write to file
// exit on failure
void update_secret_file(char* secret_str_p, unsigned int length) {
    unsigned char secret[SECRET_LENGTH] = { '\0' };
    if (getrandom(secret, sizeof(secret), 0) != sizeof(secret)) {
        mc_exit_error(__FILE__, __LINE__);
    }

    for (unsigned int ix = 0; ix < sizeof(secret); ix++) {
        snprintf(secret_str_p + ix*2, length-1, "%02x", secret[ix]);
    }
    secret_str_p[length-1] = '\0';

    unlink(SECRET_FILENAME);
    FILE* fp = fopen(SECRET_FILENAME, "w");
    if (!fp) {
        mc_exit_error(__FILE__, __LINE__);
    }
    if (fwrite(secret_str_p, 1, length-1, fp) != length-1) {
        mc_exit_error(__FILE__, __LINE__);
    }
    fclose(fp);
}

// get the current secret from file and verify validity
// exit on failure
void get_secret_file(char* secret_str_p) {
    int fd = open(SECRET_FILENAME, O_RDONLY);
    if (fd < 0) {
        mc_exit_error(__FILE__, __LINE__);
    }

    struct stat statdata;
    if (fstat(fd, &statdata)) {
        close(fd);
        mc_exit_error(__FILE__, __LINE__);
    }
    time_t current_time_s = time(NULL);
    if (statdata.st_mtim.tv_sec + SECRET_EXPIRY_S < current_time_s) {
        unlink(SECRET_FILENAME);
        close(fd);
        mc_exit_error(__FILE__, __LINE__);
    }
    if (read(fd, secret_str_p, SECRET_STR_LENGTH-1) != SECRET_STR_LENGTH-1) {
        mc_exit_error(__FILE__, __LINE__);
    }
    close(fd);
}

int main(int argc, char* argv[]) {
    char* clean_request_method_str = getenv("REQUEST_METHOD");
    if (!clean_request_method_str) {
        mc_exit_error(__FILE__, __LINE__);
    }
    mc_match_regex(regex_alphanumeric_str, clean_request_method_str, __FILE__, __LINE__);

    // if not POSTed then error
    const char method[] = "POST";
    if (mc_string_compare(clean_request_method_str, method, sizeof(method)-1)) {
        mc_exit_error(__FILE__, __LINE__);
    }

    // check REQUEST_URI
    enum { REQUEST_INVALID, REQUEST_AUTH, REQUEST_UCI } request_type = REQUEST_INVALID;
    {
        // SCRIPT_FILENAME='/www/cgi-bin/luci/rpc/auth'
        char* env_str = getenv("SCRIPT_FILENAME");
        if (!env_str) {
            mc_exit_error(__FILE__,__LINE__);
        }
        mc_match_regex(regex_url_str, env_str, __FILE__, __LINE__);
        const char auth_uri[] = "/www" MINIM_LUCI_CGI_PATH "/rpc/auth";
        const char uci_uri[] =  "/www" MINIM_LUCI_CGI_PATH "/rpc/uci";
        if (!strcmp(auth_uri, env_str)) {
            request_type = REQUEST_AUTH;
        } else if (!strcmp(uci_uri, env_str)) {
            request_type = REQUEST_UCI;
        }
    }

    if (request_type != REQUEST_AUTH && request_type != REQUEST_UCI) {
        mc_exit_error(__FILE__, __LINE__);
    }

    if (request_type == REQUEST_AUTH) {
        char clean_password_str[sizeof(MAX_PASSWORD_EXAMPLE)*2] = { '\0' }; // current password formulate is 6+6+3, allow 2x
        {
            // read posted data from stdin
            const char example_str[] = "{\"id\":12345678,\"method\":\"login\",\"params\":[\"root\",\"" MAX_PASSWORD_EXAMPLE MAX_PASSWORD_EXAMPLE "\"]}";
            char buffer[sizeof(example_str)] = { 0 };
            if (read(STDIN_FILENO, buffer, sizeof(buffer)-1) < 0) {
                mc_exit_error(__FILE__, __LINE__);
            }

            // {"id":1,"method":"login","params":["root","felixoscar123"]}
            // verify user name
            const char* params_p = strchr(buffer, '[');
            if (!params_p) {
                mc_exit_error(__FILE__, __LINE__);
            }
            const char username[] = "[\"root\",\"";
            if (mc_string_compare(params_p, username, sizeof(username)-1)) {
                mc_exit_error(__FILE__, __LINE__);
            }
            // identify password
            const char* password_p = params_p + sizeof(username) - 1;
            char* password_end_p = strchr(password_p, '"');
            if (!password_end_p) {
                mc_exit_error(__FILE__, __LINE__);
            }
            *password_end_p = '\0';
            // sanitise password (set at manufacture A-Za-a0-9 only)
            mc_match_regex(regex_alphanumeric_str, password_p, __FILE__, __LINE__);
            strncpy(clean_password_str, password_p, sizeof(clean_password_str)-1);
            clean_password_str[sizeof(clean_password_str)-1] = '\0';
        }

        mc_verify_root_password(clean_password_str);
        char secret_str[SECRET_STR_LENGTH] = { '\0' };
        update_secret_file(secret_str, SECRET_STR_LENGTH);

        // {"id":1,"result":"a191c1c171c210def536e5279ed0c67f","error":null}
        fprintf(stdout,
                "Status: 200 OK\r\n"
                "Content-type: application/json\r\n"
                "\r\n"
                "{\"id\":null,\"result\":\"%s\",\"error\":null}\r\n"
                , secret_str);
    } else if (request_type == REQUEST_UCI) {
        char secret_str[SECRET_STR_LENGTH] = { '\0' };
        // read and validate saved secret, exit on fail
        get_secret_file(secret_str);
        // identify supplied secret
        char clean_auth_str[SECRET_STR_LENGTH] = { '\0' }; // current password formulate is 6+6+3, allow 2x
        {
            // REQUEST_URI='/cgi-bin/luci/rpc/uci?auth=awesome'
            char* env_str = getenv("REQUEST_URI");
            if (!env_str) {
                mc_exit_error(__FILE__, __LINE__);
            }
            mc_match_regex(regex_url_str, env_str, __FILE__, __LINE__);

            const char uri_prefix_str[] = MINIM_LUCI_CGI_PATH "/rpc/uci?auth=";
            if (strncmp(env_str, uri_prefix_str, sizeof(uri_prefix_str)-1)) {
                mc_exit_error(__FILE__, __LINE__);
            }
            strncpy(clean_auth_str, env_str+sizeof(uri_prefix_str)-1, sizeof(clean_auth_str)-1);
        }
        // validate supplied secret
        if (mc_string_compare(secret_str, clean_auth_str, sizeof(secret_str))) {
            mc_exit_error(__FILE__, __LINE__);
        }
        // for the uci endpoint we support delete, set and commit
        // {"method":"delete","params":["network","wan","ipaddr"]}
        // {"method":"set","params":["network","wan","proto","pppoe"]}
        // {"method":"commit","params":["network"]}

        // read posted data from stdin and identify the method, allow generous maximum lengths for uci parameter names and values
        const char example_str[] = "{\"method\":\"delete\",\"params\":[\"network\",\"_123456789_123456789\",\"_123456789_123456789\",\"_123456789_123456789_123456789_123456789_123456789\"]}";
        char buffer[sizeof(example_str)] = { 0 };
        if (read(STDIN_FILENO, buffer, sizeof(buffer)-1) < 0) {
            mc_exit_error(__FILE__, __LINE__);
        }
        const char method_str[] = "{\"method\":\"";
        if (strncmp(buffer, method_str, sizeof(method_str)-1)) {
                mc_exit_error(__FILE__, __LINE__);
        }
        enum { METHOD_UNKNOWN, METHOD_DELETE, METHOD_SET, METHOD_COMMIT } method = METHOD_UNKNOWN;
        const char method_delete_str[] = "delete";
        const char method_set_str[]    = "set";
        const char method_commit_str[] = "commit";
        char* line_method_p = buffer + sizeof(method_str) - 1;
        if (!strncmp(line_method_p, method_delete_str, sizeof(method_delete_str)-1)) {
            method = METHOD_DELETE;
        } else if (!strncmp(line_method_p, method_set_str, sizeof(method_set_str)-1)) {
            method = METHOD_SET;
        } else if (!strncmp(line_method_p, method_commit_str, sizeof(method_commit_str)-1)) {
            method = METHOD_COMMIT;
        } else {
            mc_exit_error(__FILE__, __LINE__);
        }

        if (method == METHOD_COMMIT) {
            fprintf(stderr, "commit\n");
            puts("Status: 200 OK\r\n"
                 "Content-type: text/plain\r\n"
                 "\r\n"
                 "Done\r\n");
            fflush(stdout);
            // restart services as luci did
            if (!execl("/sbin/luci-reload", "/sbin/luci-reload", "network", (char*) NULL)) {
                mc_exit_error(__FILE__, __LINE__);
            }
        } else {
            // find and reformat the param string
            // eg. "params":["network","wan","dns","8.8.8.8 8.8.8.4"]}
            const char params_start_str[] = "\"params\":[\"";
            char* line_params_start_p = strstr(buffer, params_start_str);
            if (!line_params_start_p) {
                mc_exit_error(__FILE__, __LINE__);
            }
            line_params_start_p += sizeof(params_start_str)-1;
            // we only support network params
            const char network_param_str[] = "network\",\"";
            if (strncmp(line_params_start_p, network_param_str, sizeof(network_param_str)-1)) {
                mc_exit_error(__FILE__, __LINE__);
            }
            // look for the end delimiter and truncate the string there
            const char params_end_str[] = "\"]}";
            char* line_params_end_p = strstr(line_params_start_p, params_end_str);
            if (!line_params_end_p) {
                mc_exit_error(__FILE__, __LINE__);
            }
            *line_params_end_p = '\0';
            // check the overall length is viable
            if (strlen(line_params_start_p) < UCI_PARAMS_MINIMUM_LENGTH) {
                mc_exit_error(__FILE__, __LINE__);
            }
            // reformat at most 2 delimiters from abc","def","ghi to abc.def.ghi
            const char delimiter_str[] = "\",\"";
            for (unsigned int ix = 0; ix < 2; ix++) {
                char* delimiter_p = strstr(line_params_start_p+UCI_PARAM_MINIMUM_LENGTH, delimiter_str);
                if (!delimiter_p) {
                    break;
                }
                // protect against start of delimeter at the end of params
                if  (delimiter_p + UCI_PARAM_MINIMUM_LENGTH >= line_params_end_p) {
                    mc_exit_error(__FILE__, __LINE__);
                }
                // replace delimeter with . and move string up
                *delimiter_p = '.';
                memmove(delimiter_p+1, delimiter_p+sizeof(delimiter_str)-1, line_params_end_p-delimiter_p-1);
            }
            // if this is a set, terminate the param and find the value
            char* line_value_p = NULL;
            if (method == METHOD_SET) {
                char* delimiter_p = strstr(line_params_start_p+UCI_PARAM_MINIMUM_LENGTH, delimiter_str);
                if (!delimiter_p) {
                    mc_exit_error(__FILE__, __LINE__);
                }
                *delimiter_p = '\0';
                line_value_p = delimiter_p+sizeof(delimiter_str)-1;
            }
            // sanitise the param
            mc_match_regex(regex_uci_param_str, line_params_start_p, __FILE__, __LINE__);
            // choosing not to sanitise the value here.  We can't be
            // sure what locale the PPPoE username and password are
            // in.
#ifndef TEST
            // allocate a uci context and locate the parameter
            struct uci_context *ctx = uci_alloc_context();
            if (!ctx) {
                mc_exit_error(__FILE__, __LINE__);
            }
            // look up the parameter
            struct uci_ptr ptr;
            char* parameter_p = strdup(line_params_start_p);
            if (!parameter_p) {
                mc_exit_error(__FILE__, __LINE__);
            }
            if (uci_lookup_ptr(ctx, &ptr, parameter_p, true) != UCI_OK) {
                uci_free_context(ctx);
                free(parameter_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            if (ptr.target != UCI_TYPE_OPTION || (ptr.flags & UCI_LOOKUP_DONE) == 0) {
                uci_free_context(ctx);
                free(parameter_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            if (method == METHOD_DELETE) {
                if (ptr.o && uci_delete(ctx, &ptr) != UCI_OK) {
                    // delete only if there is a value
                    uci_free_context(ctx);
                    free(parameter_p);
                    mc_exit_error(__FILE__, __LINE__);
                }
                fprintf(stderr, "web_rpc: deleted %s\n", line_params_start_p);
            } else if (method == METHOD_SET) {
                // set the value
                ptr.value = line_value_p;
                if (uci_set(ctx, &ptr) != UCI_OK) {
                    uci_free_context(ctx);
                    free(parameter_p);
                    mc_exit_error(__FILE__, __LINE__);
                }
                fprintf(stderr, "web_rpc: set %s to %s\n", line_params_start_p, line_value_p);
            }
            // always commit
            if (uci_commit(ctx, &ptr.p, false) != UCI_OK) {
                uci_free_context(ctx);
                free(parameter_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            uci_free_context(ctx);
            free(parameter_p);
#else
            puts(line_params_start_p);
            if (line_value_p) {
                puts(line_value_p);
            }
#endif
        }
        // {"id":1,"result":true,"error":null}
        fprintf(stdout,
                "Status: 200 OK\r\n"
                "Content-type: application/json\r\n"
                "\r\n"
                "{\"id\":null,\"result\":true,\"error\":null}\r\n");
    } else {
        mc_exit_error(__FILE__, __LINE__);
    }
}
