#ifndef COMMIT_BUILDER_H
# define COMMIT_BUILDER_H

# include <stddef.h>
#include "auto_commit.h"

char *strBuildCommitMessage(const char *sPath, t_commit_type eType);

#endif