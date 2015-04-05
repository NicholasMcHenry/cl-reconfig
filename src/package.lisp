;;;; package.lisp
;;;;
;;;; Copyright (c) 2015 Nicholas A McHenry <nick@futilityquest.com>

(defpackage #:cl-reconfig
  (:use #:cl #:alexandria)
  (:export :with-config
	   :set-property
	   :delete-property
	   :add-dependencies
	   :delete-dependency
	   :add-files
	   :set-description
	   :set-author
	   :set-license
	   :set-serial
	   :set-dependencies
	   :set-components
	   :define-property-setter
	   :add-deps
	   :del-dep))


