(ASDF/DEFSYSTEM:DEFSYSTEM #:CL-RECONFIG
  :DESCRIPTION
  "Modify .asd files without leaving your REPL"
  :AUTHOR
  "Nicholas A McHenry <nick@futilityquest.com>"
  :LICENSE
  "LGPL"
  :DEPENDS-ON
  (#:ALEXANDRIA)
  :SERIAL
  T
  :COMPONENTS
  ((:FILE "package") (:FILE "cl-reconfig")))