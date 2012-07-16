;;; loaddefs.el --- automatically extracted autoloads
;;
;;; Code:

;;;***

;;;### (autoloads (htmlize-many-files-dired htmlize-many-files htmlize-file
;;;;;;  htmlize-region htmlize-buffer) "elpa-to-submit/htmlize" "elpa-to-submit/htmlize.el"
;;;;;;  (20347 41920))
;;; Generated autoloads from elpa-to-submit/htmlize.el

(autoload 'htmlize-buffer "elpa-to-submit/htmlize" "\
Convert BUFFER to HTML, preserving colors and decorations.

The generated HTML is available in a new buffer, which is returned.
When invoked interactively, the new buffer is selected in the current
window.  The title of the generated document will be set to the buffer's
file name or, if that's not available, to the buffer's name.

Note that htmlize doesn't fontify your buffers, it only uses the
decorations that are already present.  If you don't set up font-lock or
something else to fontify your buffers, the resulting HTML will be
plain.  Likewise, if you don't like the choice of colors, fix the mode
that created them, or simply alter the faces it uses.

\(fn &optional BUFFER)" t nil)

(autoload 'htmlize-region "elpa-to-submit/htmlize" "\
Convert the region to HTML, preserving colors and decorations.
See `htmlize-buffer' for details.

\(fn BEG END)" t nil)

(autoload 'htmlize-file "elpa-to-submit/htmlize" "\
Load FILE, fontify it, convert it to HTML, and save the result.

Contents of FILE are inserted into a temporary buffer, whose major mode
is set with `normal-mode' as appropriate for the file type.  The buffer
