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
