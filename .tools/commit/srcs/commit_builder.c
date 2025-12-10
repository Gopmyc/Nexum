#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "auto_commit.h"
#include "file_utils.h"
#include "commit_rules.h"

static const t_commit_rule *psFindRule(const char *sPath) {
	return psFindDynamicRule(sPath);
}

static char *strDupSafe(const char *s)
{
	if (!s) return NULL;
	size_t i = strlen(s) + 1;
	char *p = malloc(i);
	if (!p) return NULL;
	memcpy(p, s, i);
	return p;
}

char *strBuildCommitMessage(const char *sPath, t_commit_type eType)
{
	const t_commit_rule *psRule = psFindRule(sPath);
	t_commit_action act;
	char *sScope, *sFile, *sMsg;
	const char *sTag, *sEmoji, *sDesc;
	size_t iLen;

	if (!sPath) return NULL;

	if (psRule && eType >= 0 && eType <= COMMIT_RENAME)
		act = psRule->actions[eType];
	else
		act = (t_commit_action){FALLBACK_TAG, FALLBACK_EMOJI, FALLBACK_DESC};

	sTag = act.sTag;
	sEmoji = act.sEmoji;
	sDesc = act.sDesc;

	sScope = sGetScopeFromPath(sPath);
	sFile  = sGetFilenameFromPath(sPath);

	if (!sScope) sScope = strDupSafe(sPath);
	if (!sFile)  sFile  = strDupSafe("");

	iLen = strlen(sTag) + strlen(sScope) + strlen(sEmoji) + strlen(sDesc) + strlen(sFile) + 32;
	sMsg = malloc(iLen);
	if (!sMsg)
	{
		free(sScope);
		free(sFile);
		return NULL;
	}

	snprintf(sMsg, iLen, "%s(%s): %s - %s (%s)", sTag, sScope, sEmoji, sDesc, sFile);

	free(sScope);
	free(sFile);
	return sMsg;
}
