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
	^ 'diff -u original.txt new.txt
--- original.txt	2024-09-20 11:15:06
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
