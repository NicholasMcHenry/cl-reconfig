;;;; cl-reconfig.lisp
;;;;
;;;; Copyright (c) 2015 Nicholas A McHenry <nick@futilityquest.com>

(in-package #:cl-reconfig)

;(defvar *most-recent-system* nil)

;From serapeum. Didn't load the library as it doesn't always compile.
(declaim (inline unsplice))
(defun unsplice (form)
  "If FORM is non-nil, wrap it in a list.
  This is useful with ,@ in macros, and with `mapcan'.
  From Lparallel."
  (if form
    (list form)
    nil))

;From serapeum. Didn't load the library as it doesn't always compile.
(defmacro defalias (alias &body (def &optional docstring))
  "Define a value as a top-level function.
  (defalias string-gensym (compose #'gensym #'string))
  Like (setf (fdefinition ALIAS) DEF), but with a place to put
  documentation and some niceties to placate the compiler.
  Name from Emacs Lisp."
  `(progn
     ;; Give the function a temporary definition at compile time so
     ;; the compiler doesn't complain about it's being undefined.
     (eval-when (:compile-toplevel)
       (unless (fboundp ',alias)
         (defun ,alias (&rest args)
           (declare (ignore args)))))
     (eval-when (:load-toplevel :execute)
       (compile ',alias ,def)
       ,@(unsplice
         (when docstring
           `(setf (documentation ',alias 'function) ,docstring))))
     ',alias))

(defun add-dependencies (config &rest dependencies)
  "Appends inputs to the :depends-on list."
  (appendf (getf (cddr config) :depends-on) dependencies))
(defalias add-deps #'add-dependencies)

(defun delete-dependency (config dependency)
  "Deletes dependency from the :depends-on list if it exists.
   Assumes keywords, cannot remove uniterned symbols. 
   Thus works with :hunchentoot but not #:hunchentoot"
  (deletef (getf (cddr config) :depends-on) dependency))
(defalias del-dep #'delete-dependency)

(defun add-files (config &rest files)
  "Transforms '(file1 file2 ..) to '((:file file1) (:file file2) ..) 
  then appends that to the :components list."
  (appendf (getf (cddr config) :components) 
	   (mapcar (lambda (f) (list :file f)) files)))

;(defun delete-file (condig file)

(defmacro define-property-setter (fname key &optional (docstring ""))
  "Create a convenience function to swap out or add a value to the .asd config.
  Gratuitious example:
    (define-property-setter set-dependencies :depends-on)
  Expands to this:
  (defun set-dependencies (config &rest dependencies)
    (setf (getf (cddr config) :depends-on) dependencies))"
  `(defun ,fname (config value)
     ,docstring
     (setf (getf (cddr config) ,key) value)))

;Usage: 
;  (with-config c path
;    (set-description c value))
(define-property-setter set-description :description
  "Sets or initializes the :description to value.")
(define-property-setter set-author :author
  "Sets or initializes the :author to value.")
(define-property-setter set-license :license
  "Sets or initializes the :license to value.")
(define-property-setter set-serial :serial
  "Sets or initializes the :serial parameter to value.")
(define-property-setter set-dependencies :depends-on
  "Sets or initializes the entirety of the :depends-on list to value.
   Usually you want to use #'add-dependencies which provides a better interface.")
(define-property-setter set-components :components
  "Sets or initializes the entirety of the :depends-on list to value.
   Usually you want to use #'add-files which provides a better interface.")

(defmacro set-property (config key value)
  "Generic property setter. Defined so that arbitrary properties can be added or changed when no convenience function like #'set-license is pre-defined."
  `(setf (getf (cddr ,config) ,key) ,value))

(defun delete-property (config key)
  "Generic property deleter. Removes the provided key and its value from the config file."
  (delete-from-plistf (cddr config) key))

(defmacro with-config (var path &body body)
  "Reads .asd config at filepath and binds the result to var. 
   Then executes body & writes back to the config file.
   Assumes no code besides (asdf:defsystem ...) is in the file.
   Eats comments. Overwrites."
  ;TODO - handle errors so that my file doesn't get eaten
  `(let ((,var)) 
     (with-open-file (strm (ensure-directories-exist ,path) 
			   :direction :input
			   :if-does-not-exist :create)
       (setf ,var (read strm)))
     (with-open-file (strm ,path
			   :direction :output
			   :if-exists :supersede)
       
       (format strm "~S" ,var))))
