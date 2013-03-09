# Turn darcs patches into git commits
#
# This code can handle:
# * adding files
# * modifying file contents
# * removing files
# * adding directories (ignored)
# * removing directories (ignored)
# * renaming files
# * renaming empty directories
#
# The code can't handle:
# * renaming directories that contain files
#
# Renaming directories that contain files is too hard,
# because by the time we know it's renamed, it's too late
# to tell git to move it. I think we'd have to put it
# back in its original location(!), then do a git mv and
# hope it ended up where we wanted it. Not today.
module GitHelpers
  def create_git_commit(message_prefix = "")
    git_add(changed_or_added_files)
    git_rm(deleted_files)
    git_commit(message_prefix + darcs_last_patch_name)
  end

  private

  def git_add(files)
    return if files.empty?
    # This will add all hunks in the changed files to git - this may
    # be too much, but it's not a big enough problem to care about
    system "git add #{files.join(" ")}"
  end

  def git_rm(files)
    return if files.empty?
    system "git rm #{files.join(" ")}"
  end

  def git_commit(message)
    system %'git commit -m "#{escape(message)}"'
  end

  def escape(message)
    message.gsub('"', '\"')
  end

  def git_tracked_files
    # Darcs prefixes file paths with "./", git doesn't
    `git ls-tree --name-only -r HEAD`.
      split("\n").
      map { |filename| "./" + filename }
  end

  def changed_or_added_files
    darcs_changed_files.select { |filename|
      # Only add things into git that are _files_ (no directories)
      File.file?(filename)
    }
  end

  def deleted_files
    darcs_changed_files.reject { |filename|
      # If it doesn't exist, it must have been deleted
      File.exist?(filename)
    }.select { |filename|
      # But don't remove it unless git knows about it -
      # we're probably removing a directory, which git won't be tracking
      git_tracked_files.include?(filename)
    }
  end

  def darcs_changed_files
    ENV["DARCS_FILES"].split("\n")
  end

  def darcs_last_patch_name
    last_patch_info = `darcs log --last=1`
    patch_name_line = last_patch_info.split("\n").detect { |line| line =~ /^\s*\*/ }
    patch_name = /\*\s+(.*)/.match(patch_name_line)[1]

    patch_name or raise "Couldn't extract patch name"
  end
end
