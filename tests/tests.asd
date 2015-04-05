;;;; tests.asd
;;;;
;;;; Copyright (c) 2015 Nicholas A McHenry <nick@futilityquest.com>

(asdf:defsystem #:tests
  :description "Describe tests here"
  :author "Nicholas A McHenry <nick@futilityquest.com>"
  :license "Specify license here"
  :depends-on (#:fiveam
               #:cl-reconfig)
  :serial t
  :components ((:file "package")
               (:file "tests")))

