#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#ifdef _WIN32
#include <direct.h>
#define PATH_SEP "\\"
#define getcwd _getcwd
#else
#include <unistd.h>
#define PATH_SEP "/"
#endif

int directory_exists(const char *path)
{
	struct stat s;
	return (stat(path, &s) == 0 && (s.st_mode & S_IFDIR));
}

int run_command(const char *cmd)
{
	int res = system(cmd);
	if (res != 0)
		fprintf(stderr, "Error running command: %s\n", cmd);
	return res;
}

int get_srcs_parent_name(char *buffer, size_t size)
{
	char cwd[512];
	if (!getcwd(cwd, sizeof(cwd)))
	{
		perror("getcwd");
		return 0;
	}
	char path[512];
	snprintf(path, sizeof(path), "%s%s%s", cwd, PATH_SEP, "srcs");

	char *p = strrchr(path, PATH_SEP[0]);
	if (!p) return 0;
	*p = '\0';
	p = strrchr(path, PATH_SEP[0]);
	if (!p) strncpy(buffer, path, size);
	else strncpy(buffer, p + 1, size);
	buffer[size-1] = '\0';
	return 1;
}

int main(void)
{
	DIR *d;
	struct dirent *entry;
	char cmd[1024];
	char prog_name[256];
	char exe_path[512];

	if (!get_srcs_parent_name(prog_name, sizeof(prog_name)))
	{
		fprintf(stderr, "Cannot determine program name from srcs/\n");
		return 1;
	}

	if (!directory_exists("builds"))
	{
		fprintf(stderr, "builds/ folder not found.\n");
		return 1;
	}

	if (directory_exists("builds"))
	{
		d = opendir("builds");
		if (!d) { perror("opendir"); return 1; }
		while ((entry = readdir(d)) != NULL)
		{
			size_t len = strlen(entry->d_name);
			if (len > 3 && strcmp(entry->d_name + len - 3, ".rc") == 0)
			{
				char rc_path[512];
				char obj_path[512];
				char tmp[256];
				strcpy(tmp, entry->d_name);
				char *dot = strrchr(tmp, '.');
				if (dot) *dot = '\0';
				snprintf(rc_path, sizeof(rc_path), "builds%s%s", PATH_SEP, entry->d_name);
				snprintf(obj_path, sizeof(obj_path), "%s.o", tmp);
				snprintf(cmd, sizeof(cmd), "windres %s %s", rc_path, obj_path);
				printf("Compiling RC: %s -> %s\n", rc_path, obj_path);
				if (run_command(cmd) != 0) { closedir(d); return 1; }
			}
		}
		closedir(d);
	}

	if (directory_exists("srcs"))
	{
		d = opendir("srcs");
		if (!d) { perror("opendir srcs"); return 1; }
		while ((entry = readdir(d)) != NULL)
		{
			size_t len = strlen(entry->d_name);
			if (len > 2 && strcmp(entry->d_name + len - 2, ".c") == 0)
			{
				char c_path[512];
				char obj_path[512];
				snprintf(c_path, sizeof(c_path), "srcs%s%s", PATH_SEP, entry->d_name);
				strcpy(obj_path, entry->d_name);
				char *dot = strrchr(obj_path, '.');
				if (dot) *dot = '\0';
				strcat(obj_path, ".o");

				if (directory_exists("includes"))
					snprintf(cmd, sizeof(cmd), "gcc -Iincludes -c %s -o %s", c_path, obj_path);
				else
					snprintf(cmd, sizeof(cmd), "gcc -c %s -o %s", c_path, obj_path);

				printf("Compiling C: %s -> %s\n", c_path, obj_path);
				if (run_command(cmd) != 0) { closedir(d); return 1; }
			}
		}
		closedir(d);
	}
	else
	{
		printf("srcs/ folder not found. Skipping C compilation.\n");
	}

	snprintf(exe_path, sizeof(exe_path), "builds%s%s", PATH_SEP, prog_name);
	printf("Linking executable: %s\n", exe_path);

	d = opendir(".");
	if (!d) { perror("opendir ."); return 1; }
	char link_cmd[2048] = "gcc -mconsole -o ";
	strcat(link_cmd, exe_path);
	strcat(link_cmd, " ");
	while ((entry = readdir(d)) != NULL)
	{
		size_t len = strlen(entry->d_name);
		if (len > 2 && strcmp(entry->d_name + len - 2, ".o") == 0)
		{
			strcat(link_cmd, entry->d_name);
			strcat(link_cmd, " ");
		}
	}
	closedir(d);

	if (run_command(link_cmd) != 0) return 1;

#ifdef _WIN32
	snprintf(cmd, sizeof(cmd), "del /Q *.o");
#else
	snprintf(cmd, sizeof(cmd), "rm -f *.o");
#endif
	run_command(cmd);

	printf("Build finished successfully: %s\n", exe_path);
	return 0;
}
