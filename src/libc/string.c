#include "string.h"

void *memcpy(void *dest, const void *src, size_t n) {
  char *d = (char *)dest;
  const char *s = (const char *)src;
  while (n--) {
    *d++ = *s++;
  }
  return dest;
}

void *memset(void *s, int c, size_t n) {
  char *p = (char *)s;
  while (n--) {
    *p++ = (char)c;
  }
  return s;
}

size_t strlen(const char *s) {
  size_t len = 0;
  while (*s++) {
    len++;
  }
  return len;
}

char *strcpy(char *dest, const char *src) {
  char *d = dest;
  while ((*d++ = *src++))
    ;
  return dest;
}

int strcmp(const char *s1, const char *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++;
    s2++;
  }
  return *(unsigned char *)s1 - *(unsigned char *)s2;
}

char *strcat(char *dest, const char *src) {
  char *d = dest;
  while (*d)
    d++;
  while ((*d++ = *src++))
    ;
  return dest;
}

void reverse(char *s) {
  int i, j;
  char c;
  for (i = 0, j = strlen(s) - 1; i < j; i++, j--) {
    c = s[i];
    s[i] = s[j];
    s[j] = c;
  }
}

int atoi(char *s) {
  int n = 0;
  int sign = 1;
  if (*s == '-') {
    sign = -1;
    s++;
  }
  while (*s >= '0' && *s <= '9') {
    n = n * 10 + (*s - '0');
    s++;
  }
  return n * sign;
}

void itoa(int n, char *str) {
  int i = 0;
  int sign = n;
  if (n < 0)
    n = -n;
  do {
    str[i++] = n % 10 + '0';
  } while ((n /= 10) > 0);
  if (sign < 0)
    str[i++] = '-';
  str[i] = '\0';
  reverse(str);
}

void hex_to_ascii(int n, char *str) {
  str[0] = '0';
  str[1] = 'x';
  int zeros = 0;
  int i = 2;
  for (int j = 28; j >= 0; j -= 4) {
    int digit = (n >> j) & 0xF;
    if (digit > 0 || zeros) {
      str[i++] = (digit > 9) ? (digit - 10 + 'a') : (digit + '0');
      zeros = 1;
    }
  }
  if (!zeros)
    str[i++] = '0';
  str[i] = '\0';
}
