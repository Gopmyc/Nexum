#ifndef VERSION_H
#define VERSION_H

#include <stdbool.h>
#include <stddef.h>

typedef struct s_version
{
	int major;
	int minor;
	int patch;
	char commit[16];
} t_version;

bool bLoadVersion(t_version *pVer);
bool bSaveVersion(const t_version *pVer);
void vIncrementVersion(t_version *pVer, bool bIncrement);
void vUpdateCommitHash(t_version *pVer);
void vGetVersionString(const t_version *pVer, char *sOut, size_t iSize);

#endif