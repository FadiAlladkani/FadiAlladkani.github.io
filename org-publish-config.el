;; Enable exporter and org-mode
(require 'ox)
(require 'org)

;; Disable adding the validation link
(setq org-html-validation-link nil)
;; Disable using underscores to make a word into a subscript
(setq org-export-with-sub-superscripts nil)

;; Since I don't know how to use org/elisp's timestamp conversion functions
;; And I get the month as an integer, these will map the month number to the actual name
(setq month-names '("January" "February" "March" "April" "May" "June" "July"
		    "August" "September" "October" "November" "December"))

;; Site title
(setq site-title "Org Sync Files")

;; Custom exporter functions
(defun pico-html-template (contents info)
  (concat
   "<!DOCTYPE html>\n"
   (format "<html lang=\"%s\">\n" (plist-get info :language))
   "<head>\n"
   (format "<meta charset=\"%s\">\n"
	   (coding-system-get org-html-coding-system 'mime-charset))
   (format "<title>%s</title>\n"
	   (org-export-data (or (plist-get info :title) "") info))
   (format "<meta name=\"author\" content=\"%s\">\n"
	   (org-export-data (plist-get info :author) info))
   "<link href=\"/css/pico.min.css\" rel=\"stylesheet\" style=\"text/css\" />\n"
   "</head>\n"
   "<body>\n"
   "<main class=\"container\">"
   "<hgroup>"
   (format "<h1><a href=\"/index.html\">%s</a></h1>" site-title)
   "<h2>"
   (format "%s"
	   (file-name-base (plist-get info :input-file)))
   "</h2>"
   "</hgroup>"
   contents
   "</main>"
   "</body>\n"
   "</html>\n"))

(defun format-timestamp (timestamp)
  (format "%s %s, %s %s:%s"
	  (nth (- (org-element-property :month-start timestamp) 1) month-names)
	  (org-element-property :day-start timestamp)
	  (org-element-property :year-start timestamp)
	  (org-element-property :hour-start timestamp)
	  (org-element-property :minute-start timestamp)))

(defun pico-html-headline (object contents info)
  (concat
   "<details><summary>"
   (if (string= "TODO" (org-element-property :todo-keyword object))
       "<ins><strong>TODO </strong></ins>" "")
   (if (string= "DONE" (org-element-property :todo-keyword object))
       (format "<mark><em data-tooltip=\"%s\">DONE </em></mark>"
	       (format-timestamp (org-element-property :closed object))))
   (format "%s</summary>"
	   (nth 0 (org-element-property :title object)))
   "<blockquote>"
   contents
   "</blockquote>"
   "</details>\n"))

;; Custom exporter
(org-export-define-derived-backend 'pico-html 'html
				   :translate-alist '((template . pico-html-template)
						      (headline . pico-html-headline)))

(setq org-html-toplevel-hlevel 5)
(setq org-export-with-toc nil)

;; Publisher with the custom exporter
(defun org-html-publish-to-pico-html (plist filename pub-dir)
  (org-publish-org-to 'pico-html filename ".html" plist pub-dir))

;; Declare primary project
(setq org-publish-project-alist
      '(("primary"
	 :base-directory "./"
	 :publishing-directory "./out"
	 :recursive 1
	 :auto-sitemap 1
	 :sitemap-filename "index.html"
	 :sitemap-title "Org-Sync Files"
	 :publishing-function org-html-publish-to-pico-html)
	("css"
	 :base-directory "./styling/pico/css"
	 :base-extension "css"
	 :publishing-directory "./out/css"
	 :publishing-function org-publish-attachment)))

;; Publish all projects to the publishing directory
(org-publish-all t)
