// (c) Minim Inc 2022

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <crypt.h>
#include <regex.h>

#include "minim_common.h"

#ifdef TEST
#    define SHADOW_FILE_PATH "shadow"
#else
#    define SHADOW_FILE_PATH "/etc/shadow"
#endif

// constant time string compare (return 0 on match, -1 on mismatch)
// from https://codahale.com/a-lesson-in-timing-attacks/
int mc_string_compare(const char* str1, const char* str2, unsigned int len) {
    if (str1 == NULL || str2 == NULL) {
        return -1;
    }
    unsigned int result = 0;
    unsigned int idx = 0;
    do {
        result |= (*str1 ^ *str2);
        str1++;
        str2++;
        idx++;
    } while (*str1 != '\0' && *str2 != '\0' && idx != len);

    if (idx == len) {
        return result;
    }

    if (*str1 == '\0' && *str2 == '\0') {
        return result;
    }

    return -1;
}

void mc_exit_error(const char* file, unsigned int line) {
    fputs("Status: 404 Not Found\r\n\r\n", stdout);
    fprintf(stderr, "%s error on line %d\n", file, line);
    exit(-1);
}

// ==========================================================
// verify the root password against the shadow password file
// won't return if verification fails
void mc_verify_root_password(const char* clean_password_str) {
    FILE* shadow_fp = fopen(SHADOW_FILE_PATH, "r");
    if (!shadow_fp) {
        mc_exit_error(__FILE__, __LINE__);
    }
    do {
        char* line_p = NULL; // let getline malloc us a chunk the correct size
        size_t linelen = 0;
        if (getline(&line_p, &linelen, shadow_fp) <= 0) {
            if (line_p) {
                free(line_p);
                line_p = NULL;
            }
            break;
        }
        const char rootprefix[] = "root:";
        if (!mc_string_compare(rootprefix, line_p, sizeof(rootprefix)-1)) {
            // identify password and settings/salt in shadow file
            char* setting_p = &line_p[sizeof(rootprefix)-1];
            char* pass_p = strchr(setting_p+1, '$');
            if (!pass_p) {
                fclose(shadow_fp);
                free(line_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            pass_p = strchr(pass_p+1, '$');
            if (!pass_p) {
                fclose(shadow_fp);
                free(line_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            *pass_p = '\0';
            pass_p++;
            char* end_p = strchr(pass_p, ':');
            if (!end_p) {
                fclose(shadow_fp);
                free(line_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            *end_p = '\0';
            // encrypt and compare supplied password
            char* crypt_p = crypt(clean_password_str, setting_p);
            crypt_p = strchr(crypt_p+1, '$');
            if (!crypt_p) {
                fclose(shadow_fp);
                free(line_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            crypt_p = strchr(crypt_p+1, '$');
            if (!crypt_p) {
                fclose(shadow_fp);
                free(line_p);
                mc_exit_error(__FILE__, __LINE__);
            }
            crypt_p++;
            if (!mc_string_compare(pass_p, crypt_p, strlen(crypt_p))) {
                fclose(shadow_fp);
                free(line_p);
                // SUCCESS
                return;
            }
        }
        free(line_p);
        line_p = NULL;
    } while (1);

    fclose(shadow_fp);
    mc_exit_error(__FILE__, __LINE__);
}

// ==========================================================
// Determine if a string matches a regex, exit if string does not match
void mc_match_regex(const char* regex_str_p, const char* str_p, const char* file_p, unsigned int line) {
    regex_t regex;
    if (regcomp(&regex, regex_str_p, 0)) {
        mc_exit_error(file_p, line);
    }

    if (regexec(&regex, str_p, 0, NULL, 0)) {
        regfree(&regex);
        mc_exit_error(file_p, line);
    }
    regfree(&regex);
}
