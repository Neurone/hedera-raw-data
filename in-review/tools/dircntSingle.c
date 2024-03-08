#include <stdio.h>
#include <dirent.h>

int main(int argc, char *argv[])
{
    DIR *dir;
    struct dirent *ent;
    long count = 0;

    dir = opendir(argv[1]);

    while ((ent = readdir(dir)))
        ++count;

    closedir(dir);

    printf("%s contains %ld files\n", argv[1], count);

    return 0;
}