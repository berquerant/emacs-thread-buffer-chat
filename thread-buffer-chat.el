;;; thread-buffer-chat.el --- chat threads -*- lexical-binding: t -*-

;; Author: berquerant
;; Maintainer: berquerant
;; Package-Requires: ((cl-lib "1.0"))
;; Created: 6 Sep 2023
;; Version: 0.2.0
;; Keywords: thread buffer
;; URL: https://github.com/berquerant/emacs-thread-buffer-chat

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Code:

;; TODO: add to Package-Requires
(require 'little-async)  ; https://github.com/berquerant/emacs-little-async
(require 'thread-buffer) ; https://github.com/berquerant/emacs-thread-buffer
(require 'cl-lib)

(defgroup thread-buffer-chat nil
  "Thread buffer chat.")

(defcustom thread-buffer-chat-process-name "thread-buffer-chat-process"
  "Process name of the spawned process."
  :group 'thread-buffer-chat
  :type 'string)

(defcustom thread-buffer-chat-process-buffer-name "*thread-buffer-chat-process*"
  "Process buffer name of the spawned process."
  :group 'thread-buffer-chat
  :type 'string)

(defcustom thread-buffer-chat-default-timeout 60
  "Default command timeout."
  :group 'thread-buffer-chat
  :type 'number)

(defcustom thread-buffer-chat-default-buffer-template "*thread-buffer-chat-%d*"
  "Default buffer template."
  :group 'thread-buffer-chat
  :type 'string)

(defcustom thread-buffer-chat-default-buffer-regex "\*thread-buffer-chat-[0-9+]\*"
  "Default buffer regex."
  :group 'thread-buffer-chat
  :type 'string)

(cl-defun thread-buffer-chat-start
    (command input &key timeout buffer-template buffer-regex stderr append no-switch)
  "Start chat with `thread-buffer' by COMMAND.

COMMAND read INPUT from stdin, COMMAND and INPUT are required.
Returns a spawned process.

TIMEOUT is timeout seconds of COMMAND.
BUFFER-TEMPLATE is a template of the thread buffer name,
e.g. `*thread-%d*'.
BUFFER-REGEX is used to check if the current buffer is a thread buffer,
e.g. `\*thread-[0-9]\*'.
STDERR is a buffer name for stderr.
APPEND, NO-SWITCH, for other details, see `thread-buffer-write'."
  (let ((timeout (* 1000 (or timeout thread-buffer-chat-default-timeout)))
        (buffer-template (or buffer-template thread-buffer-chat-default-buffer-template))
        (buffer-regex (or buffer-regex thread-buffer-chat-default-buffer-regex)))

    (defun thread-buffer-chat-start--internal-output-filter (p output)
      (thread-buffer-write output buffer-template buffer-regex append no-switch))

    (little-async-start-process command
                                :input input
                                :process-name thread-buffer-chat-process-name
                                :buffer-name thread-buffer-chat-process-buffer-name
                                :stderr stderr
                                :timeout timeout
                                :filter #'thread-buffer-chat-start--internal-output-filter)))

(provide 'thread-buffer-chat)
;;; thread-buffer-chat.el ends here
