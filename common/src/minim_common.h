// (c) Minim Inc 2022

#define MINIM_LUCI_CGI_PATH "/cgi-bin/luci"

int mc_string_compare(const char* str1, const char* str2, unsigned int len);
void mc_exit_error(const char* file, unsigned int line);
void mc_verify_root_password(const char* clean_password_str);
void mc_match_regex(const char* regex_str_p, const char* str_p, const char* file_p, unsigned int line);
