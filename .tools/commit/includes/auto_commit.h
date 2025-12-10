#ifndef AUTO_COMMIT_H
# define AUTO_COMMIT_H

# include <stddef.h>

typedef enum e_commit_type
{
	COMMIT_ADD,
	COMMIT_MODIFY,
	COMMIT_DELETE,
	COMMIT_RENAME,
	COMMIT_UNKNOWN
}	t_commit_type;

typedef struct s_commit_action
{
	const char	*sTag;
	const char	*sEmoji;
	const char	*sDesc;
}	t_commit_action;

typedef struct s_commit_rule
{
	const char			*sPathPrefix;
	t_commit_action		actions[4]; // Index = t_commit_type
}	t_commit_rule;

#define ROOT_LUA_PREFIX "lua/"
#define FALLBACK_TAG "chore"
#define FALLBACK_EMOJI "🔧"
#define FALLBACK_DESC "Updated file"

#endif
