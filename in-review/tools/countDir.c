#define _GNU_SOURCE
#include <dirent.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/syscall.h>

#define BUF_SIZE 4096

struct linux_dirent
{
    long d_ino;
    off_t d_off;
    unsigned short d_reclen;
    char d_name[];
};

int countDir(char *dir)
{

    int fd, nread, bpos, numFiles = 0;
    char d_type, buf[BUF_SIZE];
    struct linux_dirent *dirEntry;

    fd = open(dir, O_RDONLY | O_DIRECTORY);
    if (fd == -1)
    {
        puts("open directory error");
        exit(3);
    }
    while (1)
    {
        nread = syscall(SYS_getdents, fd, buf, BUF_SIZE);
        if (nread == -1)
        {
            puts("getdents error");
            exit(1);
        }
        if (nread == 0)
        {
            break;
        }

        for (bpos = 0; bpos < nread;)
        {
            dirEntry = (struct linux_dirent *)(buf + bpos);
            d_type = *(buf + bpos + dirEntry->d_reclen - 1);
            if (d_type == DT_REG)
            {
                // Increase counter
                numFiles++;
            }
            bpos += dirEntry->d_reclen;
        }
    }
    close(fd);

    return numFiles;
}

int main(int argc, char **argv)
{

    if (argc != 2)
    {
        puts("Pass directory as parameter");
        return 2;
    }
    printf("Number of files in %s: %d\n", argv[1], countDir(argv[1]));
    return 0;
}