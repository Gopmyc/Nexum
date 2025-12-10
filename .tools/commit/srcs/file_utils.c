#include <stdlib.h>
#include <string.h>
#include "auto_commit.h"
#include "file_utils.h"

//
// ┌────────────┐
// │ FILE TOOLS │
// └────────────┘
//

char	*sGetScopeFromPath(const char *sPath)
{
	const char	*sPos;
	char		*sOut;
	size_t		iLen;

	if (!sPath)
		return (NULL);
	sPos = strstr(sPath, ROOT_LUA_PREFIX);
	if (sPos == sPath)
	{
		const char *sAfter = sPath + strlen(ROOT_LUA_PREFIX);
		iLen = strlen(sAfter) + 1;
		sOut = malloc(iLen);
		if (!sOut)
			return (NULL);
		memcpy(sOut, sAfter, iLen);
		return (sOut);
	}
	sPos = strstr(sPath, "docs/");
	if (sPos == sPath)
	{
		const char *sAfter = sPath + strlen("docs/");
		iLen = strlen(sAfter) + 1;
		sOut = malloc(iLen);
		if (!sOut)
			return (NULL);
		memcpy(sOut, sAfter, iLen);
		return (sOut);
	}
	sPos = strstr(sPath, "tools/");
	if (sPos == sPath)
	{
		const char *sAfter = sPath + strlen("tools/");
		iLen = strlen(sAfter) + 1;
		sOut = malloc(iLen);
		if (!sOut)
			return (NULL);
		memcpy(sOut, sAfter, iLen);
		return (sOut);
	}
	sOut = malloc(strlen(sPath) + 1);
	if (!sOut)
		return (NULL);
	strcpy(sOut, sPath);
	return (sOut);
}

char	*sGetFilenameFromPath(const char *sPath)
{
	const char	*sPos;
	char		*sOut;

	if (!sPath)
		return (NULL);
	sPos = strrchr(sPath, '/');
	if (!sPos)
		sPos = strrchr(sPath, '\\');
	if (!sPos)
		return (NULL);
	sOut = malloc(strlen(sPos + 1) + 1);
	if (!sOut)
		return (NULL);
	strcpy(sOut, sPos + 1);
	return (sOut);
}
