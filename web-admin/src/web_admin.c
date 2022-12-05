// CGI admin script
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>
#include <libgen.h>
#include <sys/types.h>

#include "minim_common.h"

static const char* regex_alphanumeric_str = "^[a-zA-Z0-9]*$";
static const char* regex_url_str = "^[a-zA-Z0-9:/_-]*$";

int main(int argc, char* argv[]) {
    char* clean_request_method_str = getenv("REQUEST_METHOD");
    if (!clean_request_method_str) {
        mc_exit_error(__FILE__, __LINE__);
    }
    mc_match_regex(regex_alphanumeric_str, clean_request_method_str, __FILE__, __LINE__);

    // "/www/cgi-bin/luci/admin/minim/start_sshd"
    const char path[] = "/www" MINIM_LUCI_CGI_PATH "/admin/minim/";
    // SCRIPT_FILENAME='/www/cgi-bin/luci/rpc/auth'
    char* env_str = getenv("SCRIPT_FILENAME");
    if (!env_str) {
        mc_exit_error(__FILE__, __LINE__);
    }
    if (strncmp(env_str, path, sizeof(path)-1)) {
        mc_exit_error(__FILE__, __LINE__);
    }
    const char* clean_basename_str = basename(env_str);
    mc_match_regex(regex_url_str, clean_basename_str, __FILE__, __LINE__);

    // if not POSTed then display the basic form and exit
    const char method[] = "POST";
    if (!clean_request_method_str || strncmp(clean_request_method_str, method, sizeof(method)-1)) {
        printf("Status: 200 OK\r\n"
               "Content-type: text/html\r\n"
               "\r\n"
               "<!DOCTYPE html>\r\n"
               "<html lang=\"en\">\r\n"
               "  <head>\r\n"
               "    <meta charset=\"utf-8\">\r\n"
               "    <title>Login</title>\r\n"
               "  </head>\r\n"
               "  <body>\r\n"
               "    <form action=\"%s\" method=\"POST\">\r\n"
               "      <label for=\"username\">User name:</label><br>\r\n"
               "      <input type=\"text\" id=\"username\" name=\"username\" required><br>\r\n"
               "      <label for=\"password\">Password:</label><br>\r\n"
               "      <input type=\"password\" id=\"password\" name=\"password\" required current-password>\r\n"
               "      <input type=\"submit\" value=\"Submit\">\r\n"
               "    </form>\r\n"
               "  </body>\r\n"
               "</html>\r\n", clean_basename_str);
        exit(0);
    }
    // POST so collect posted data and parse
    char clean_password_str[30] = { '\0' }; // current password formulate is 6+6+3, allow 2x
    {
        const char post_header_str[] = "username=root&password=";
        char buffer[sizeof(clean_password_str) + sizeof(post_header_str)] = {'\0'};
        // read post data from stdin
        int read_result = read(STDIN_FILENO, buffer, sizeof(buffer)-1);
        if (read_result < 0) {
            mc_exit_error(__FILE__, __LINE__);
        }
        buffer[read_result] = '\0';
        // verify username
        if (strncmp(buffer, post_header_str, sizeof(post_header_str)-1)) {
            mc_exit_error(__FILE__, __LINE__);
        }
        // sanitise password
        const char* password_p = buffer+sizeof(post_header_str)-1;
        mc_match_regex(regex_alphanumeric_str, password_p, __FILE__, __LINE__);
        strncpy(clean_password_str, password_p, sizeof(clean_password_str)-1);
    }
    // verify password
    mc_verify_root_password(clean_password_str);

    const char unprov_basename[]     = "unprov";
    const char startsshd_basename[]  = "start_sshd";
    const char enablesshd_basename[] = "enable_sshd";
    if (!strcmp(clean_basename_str, unprov_basename)) {
        fprintf(stderr, "unprov\n");
        puts("Status: 200 OK\r\n"
             "Content-type: text/plain\r\n"
             "\r\n"
             "Done\r\n");
        fflush(stdout);
        // unprov
        if (!execl("/usr/sbin/fw_setenv", "/usr/sbin/fw_setenv", "mfg_provisioned", (char*) NULL)) {
            mc_exit_error(__FILE__, __LINE__);
        }
    } else if (!strcmp(clean_basename_str, startsshd_basename)) {
        fprintf(stderr, "start_sshd\n");
        puts("Status: 200 OK\r\n"
             "Content-type: text/plain\r\n"
             "\r\n"
             "Done\r\n");
        fflush(stdout);
        // start sshd
        if (!execl("/etc/init.d/dropbear", "/etc/init.d/dropbear", "restart_admin", (char*) NULL)) {
            mc_exit_error(__FILE__, __LINE__);
        }
    } else if (!strcmp(clean_basename_str, enablesshd_basename)) {
        fprintf(stderr, "enable_sshd\n");
        puts("Status: 200 OK\r\n"
             "Content-type: text/plain\r\n"
             "\r\n"
             "Done\r\n");
        fflush(stdout);
        // start sshd
        if (!execl("/etc/init.d/dropbear", "/etc/init.d/dropbear", "restart_admin_enable", (char*) NULL)) {
            mc_exit_error(__FILE__, __LINE__);
        }
    } else {
        mc_exit_error(__FILE__, __LINE__);
    }
}
