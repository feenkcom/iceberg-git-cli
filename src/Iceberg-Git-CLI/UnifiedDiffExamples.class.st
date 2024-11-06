Class {
	#name : #UnifiedDiffExamples,
	#superclass : #Object,
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
UnifiedDiffExamples >> exampleBarContents [
	<gtExample>
	^ 'A
B
C
D
e
F
x
G
I
J
K
L
'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleComputedGitUnifiedNoContextDiff [
	<gtExample>
	<noTets>

	^ #(

		('ABCDEF' 'ABcDeF')
		('ABCDEF' 'abc')
		('ABCDEF' 'ABEF')
		('ABCDEF' 'ABxyEF')
		('ABCDEF' 'ABxyzEF')
		('ABCDEF' 'BCDE')
		('ABCDEF' 'xABCDEFy')

	) collect: [ :spec |

		| original changed unifiedDiff firstDiff patched |

		original := String streamContents: [ :out | spec first do: [ :each | out nextPut: each; cr ] ].

		changed := String streamContents: [ :out | spec second do: [ :each | out nextPut: each; cr ] ].

		unifiedDiff := PureGitDiffTool 
			gitDiffNoContextBetween: original
			and: changed.

		firstDiff := unifiedDiff firstDiff.

		patched := firstDiff applyTo: original.

		self assert: patched equals: changed.

		firstDiff ]
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleComputedOneTwoGitUnifiedDiff [
	<gtExample>
	<noTets>
	
	| unifiedDiff firstDiff output |

	unifiedDiff := PureGitDiffTool 
			gitDiffBetween: self exampleOneContents 
			and: self exampleTwoContents.

	self assert: unifiedDiff isEmpty not.

	firstDiff := unifiedDiff firstDiff.

	self assert: firstDiff numberOfChanges equals: 3.

	output := firstDiff applyTo: self exampleOneContents.

	self assert: output equals: self exampleTwoContents.

	^ unifiedDiff
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleComputedOneTwoGitUnifiedNoContextDiff [
	<gtExample>
	<noTets>
	
	| unifiedDiff firstDiff output |

	unifiedDiff := PureGitDiffTool 
			gitDiffNoContextBetween: self exampleOneContents 
			and: self exampleTwoContents.

	self assert: unifiedDiff isEmpty not.

	firstDiff := unifiedDiff firstDiff.

	self assert: firstDiff numberOfChanges equals: 3.

	output := firstDiff applyTo: self exampleOneContents.

	self assert: output equals: self exampleTwoContents.

	^ unifiedDiff
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleFooBarGitUnifiedDiff [
	<gtExample>

	| unifiedDiff changeChunk output |

	unifiedDiff := UnifiedDiff new
		readFrom: self exampleFooBarGitUnifiedDiffOutput readStream.

	changeChunk := unifiedDiff changeChunks first.

	self 
		assert: changeChunk oldContents 
		equals: ((self exampleFooContents lines copyFrom: changeChunk oldStart to: changeChunk oldEnd)
			flatCollect: [ :each | each , String cr ] as: String).
	self
		assert: changeChunk newContents
		equals: ((self exampleBarContents lines copyFrom: changeChunk newStart to: changeChunk newEnd)
			flatCollect: [ :each | each , String cr ] as: String).

	output := changeChunk applyTo: self exampleFooContents.

	self assert: output equals: self exampleBarContents.

	^ unifiedDiff
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleFooBarGitUnifiedDiffNoContextOutput [
	<gtExample>

	"git diff --unified=0 foo.txt bar.txt"

	^ 'diff --git a/foo.txt b/bar.txt
index 475f87b..d7f6539 100644
--- a/foo.txt
+++ b/bar.txt
@@ -5 +5 @@ D
-E
+e
@@ -6,0 +7 @@ F
+x
@@ -8 +8,0 @@ G
-H
'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleFooBarGitUnifiedDiffOutput [
	<gtExample>

	"git diff foo.txt bar.txt"

	^ 'diff --git a/foo.txt b/bar.txt
index 475f87b..d7f6539 100644
--- a/foo.txt
+++ b/bar.txt
@@ -2,10 +2,10 @@ A
 B
 C
 D
-E
+e
 F
+x
 G
-H
 I
 J
 K'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleFooBarGitUnifiedNoContextDiff [
	<gtExample>

	| unifiedDiff output |

	unifiedDiff := UnifiedDiff new
		readFrom: self exampleFooBarGitUnifiedDiffNoContextOutput readStream.

	self assert: unifiedDiff numberOfChanges equals: 3.

	output := unifiedDiff applyTo: self exampleFooContents.

	self assert: output equals: self exampleBarContents.

	^ unifiedDiff
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleFooContents [
	<gtExample>
	^ 'A
B
C
D
E
F
G
H
I
J
K
L
'
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiff [
	<gtExample>
	^ UnifiedDiff new
		readFrom: self exampleGitUnifiedDiffOutput readStream
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiffByLine [
	<gtExample>
	^ UnifiedDiff new
		readFromLines: self exampleGitUnifiedDiffOutput lines readStream
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiffCollection [
	<gtExample>
	^ UnifiedDiffCollection new
		readFrom: self exampleGitUnifiedDiffCollectionOutput readStream
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleGitUnifiedDiffCollectionByLine [
	<gtExample>
	^ UnifiedDiffCollection new
		readFromLines: self exampleGitUnifiedDiffCollectionOutput lines readStream
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
UnifiedDiffExamples >> exampleOneContents [
	<gtExample>
	^ ($A to: $Z) flatCollect: [ :each | String with: each with: Character cr ] as: String
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleOneTwoGitUnifiedDiff [
	<gtExample>
	
	| unifiedDiff output |
	unifiedDiff := UnifiedDiff new
		readFromLines: self exampleOneTwoGitUnifiedDiffOutput lines readStream.

	output := unifiedDiff applyTo: self exampleOneContents.

	self assert: output equals: self exampleTwoContents.

	^ unifiedDiff
]

{ #category : #accessing }
UnifiedDiffExamples >> exampleOneTwoGitUnifiedDiffOutput [
	<gtExample>

	"git diff foo.txt bar.txt"

	^ 'diff --git a/foo.txt b/bar.txt
index a6f1d23..c5f54f4 100644
--- a/foo.txt
+++ b/bar.txt
@@ -2,7 +2,7 @@ A
 B
 C
 D
-E
+e
 F
 G
 H
@@ -10,6 +10,7 @@ I
 J
 K
 L
+x
 M
 N
 O
@@ -18,7 +19,6 @@ Q
 R
 S
 T
-U
 V
 W
 X
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

{ #category : #accessing }
UnifiedDiffExamples >> exampleTwoContents [
	<gtExample>
	| alphabet |
	alphabet := ($A to: $Z) asOrderedCollection.
	"modify: $E -> $e"
	alphabet at: 5 put: $e.
	"delete: $U"
	alphabet removeAt: 21.
	"add: $x after $L"
	alphabet add: $x afterIndex: 12.
	^ alphabet flatCollect: [ :each | String with: each with: Character cr ] as: String
]
