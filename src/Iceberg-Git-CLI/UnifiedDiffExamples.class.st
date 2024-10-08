Class {
	#name : #UnifiedDiffExamples,
	#superclass : #Object,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiff [
	<gtExample>
	^ UnifiedDiff new
		readFrom: self exampleGitUnifiedDiffOutput readStream
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiffCollection [
	<gtExample>
	^ UnifiedDiffCollection new
		readFrom: self exampleGitUnifiedDiffCollectionOutput readStream
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiffCollectionOutput [
	<gtExample>
	^ 'diff --git doc/NOTES.md doc/NOTES.md
index 3590a1b..b84738f 100644
--- doc/NOTES.md
+++ doc/NOTES.md
@@ -1,4 +1,5 @@
 # Notes
 
-These are some notes.
+These are some changed notes.
 Actually, this file is easy to change for testing purposes.
+A line added at the end.
diff --git doc/empty doc/empty
deleted file mode 100644
index e69de29..0000000
diff --git doc/test.txt doc/test.txt
new file mode 100644
index 0000000..bd9dbf5
--- /dev/null
+++ doc/test.txt
@@ -0,0 +1 @@
+what is up, doc?
\ No newline at end of file
'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiffOutput [
	<gtExample>
	^ 'diff --git a/file.txt b/file.txt
index a413be2..dc81f09 100644
--- a/file.txt
+++ b/file.txt
@@ -1,3 +1,9 @@
+This is an important
+notice! It should
+therefore be located at
+the beginning of this
+document!
+
 This part of the
 document has stayed the
 same from version to
@@ -8,13 +14,8 @@ would not be helping to
 compress the size of the
 changes.
 
-This paragraph contains
-text that is outdated.
-It will be deleted in the
-near future.
-
 It is important to spell
-check this dokument. On
+check this document. On
 the other hand, a
 misspelled word isn''t
 the end of the world.
@@ -22,3 +23,7 @@ Nothing in the rest of
 this paragraph needs to
 be changed. Things can
 be added after it.
+
+This paragraph contains
+important new additions
+to this document.
'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGtDiff [
	<gtExample>
	^ GtDiffBuilder
		computeDifferencesFrom: self exampleOriginalContents
		to: self exampleNewContents
		using: GtLineDiffSplitter ignoringEOLChars
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleNewContents [
	<gtExample>
	^ 'This is an important
notice! It should
therefore be located at
the beginning of this
document!

This part of the
document has stayed the
same from version to
version.  It shouldn''t
be shown if it doesn''t
change.  Otherwise, that
would not be helping to
compress the size of the
changes.

It is important to spell
check this document. On
the other hand, a
misspelled word isn''t
the end of the world.
Nothing in the rest of
this paragraph needs to
be changed. Things can
be added after it.

This paragraph contains
important new additions
to this document.
'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleOriginalContents [
	<gtExample>
	^ 'This part of the
document has stayed the
same from version to
version.  It shouldn''t
be shown if it doesn''t
change.  Otherwise, that
would not be helping to
compress the size of the
changes.

This paragraph contains
text that is outdated.
It will be deleted in the
near future.

It is important to spell
check this dokument. On
the other hand, a
misspelled word isn''t
the end of the world.
Nothing in the rest of
this paragraph needs to
be changed. Things can
be added after it.
'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleStandardUnifiedDiff [
	<gtExample>
	^ UnifiedDiff new
		readFrom: self exampleStandardUnifiedDiffOutput readStream
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleStandardUnifiedDiffOutput [
	<gtExample>
	^ '--- original.txt	2024-09-20 11:15:06
+++ new.txt	2024-09-20 11:15:21
@@ -1,3 +1,9 @@
+This is an important
+notice! It should
+therefore be located at
+the beginning of this
+document!
+
 This part of the
 document has stayed the
 same from version to
@@ -8,13 +14,8 @@
 compress the size of the
 changes.
 
-This paragraph contains
-text that is outdated.
-It will be deleted in the
-near future.
-
 It is important to spell
-check this dokument. On
+check this document. On
 the other hand, a
 misspelled word isn''t
 the end of the world.
@@ -22,3 +23,7 @@
 this paragraph needs to
 be changed. Things can
 be added after it.
+
+This paragraph contains
+important new additions
+to this document.
'
]
