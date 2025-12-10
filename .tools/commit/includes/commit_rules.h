#ifndef COMMIT_RULES_H
#define COMMIT_RULES_H

#include "auto_commit.h"

int bLoadCommitRules(const char *sFile);
void vFreeCommitRules(void);
const t_commit_rule *psFindDynamicRule(const char *path);

#endif
