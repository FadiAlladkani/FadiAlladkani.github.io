;; Enable org-mode
(require 'org)

;; Declare primary project
(setq org-publish-project-alist
      '(("primary"
	 :base-directory "./"
	 :publishing-directory "./out"
	 :recursive 1
	 :auto-sitemap 1
	 :publishing-function org-html-publish-to-html)))

;; Publish all projects to the publishing directory
(org-publish-all)
