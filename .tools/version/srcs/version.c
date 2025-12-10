#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum e_bump { MAJOR, MINOR, PATCH } t_bump;

void exec_command(const char *cmd, char *output, size_t size)
{
	FILE	*fp;
	size_t	len;

	fp = popen(cmd, "r");
	if (!fp)
		exit(1);
	if (fgets(output, size, fp) == NULL)
		output[0] = '\0';
	len = strlen(output);
	if (len > 0 && (output[len - 1] == '\n' || output[len - 1] == '\r'))
		output[len - 1] = '\0';
	pclose(fp);
}

void push_tag(const char *tag)
{
	char	cmd[256];

	snprintf(cmd, sizeof(cmd), "git tag -a %s -m \"Release %s\"", tag, tag);
	system(cmd);
	snprintf(cmd, sizeof(cmd), "git push origin %s", tag);
	system(cmd);
}

int	main(int argc, char **argv)
{
	t_bump	type;
	char	last_tag[128];
	char	new_tag[128];
	int		major;
	int		minor;
	int		patch;
	char	*newline;

	if (argc < 2)
	{
		printf("Usage: %s patch|minor|major\n", argv[0]);
		return (1);
	}
	if (strcmp(argv[1], "major") == 0)
		type = MAJOR;
	else if (strcmp(argv[1], "minor") == 0)
		type = MINOR;
	else
		type = PATCH;

	exec_command("git tag --list \"v*\" --sort=-creatordate", last_tag, sizeof(last_tag));
	newline = strchr(last_tag, '\n');
	if (newline)
		*newline = '\0';
	if (strlen(last_tag) == 0)
		strcpy(last_tag, "v0.0.0");
	if (sscanf(last_tag, "v%d.%d.%d", &major, &minor, &patch) != 3)
		major = minor = patch = 0;

	if (type == MAJOR)
	{
		major++;
		minor = 0;
		patch = 0;
	}
	else if (type == MINOR)
	{
		minor++;
		patch = 0;
	}
	else
		patch++;

	snprintf(new_tag, sizeof(new_tag), "v%d.%d.%d", major, minor, patch);
	printf("Nouvelle version : %s\n", new_tag);

	push_tag(new_tag);

	return (0);
}
