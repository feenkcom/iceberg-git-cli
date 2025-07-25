"
I am a helper to run git diff and process the resulting output. 
"
Class {
	#name : #PureGitDiffTool,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'diffArgs'
	],
	#category : #'Iceberg-Git-CLI-Pure-Diff'
}

{ #category : #operations }
PureGitDiffTool class >> gitDiffBetween: originalContents and: changedContents [
	| temporaryDirectory dummyRepository originalFile changedFile diffTool |
	temporaryDirectory := FileReference newTempFilePrefix: 'pure-git-diff-tool-' suffix: '-tmp'.
	dummyRepository := PureGitRepository on: temporaryDirectory.
	dummyRepository ensureLocation.
	originalFile := dummyRepository location / 'a.txt'.
	originalFile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out) nextPutAll: originalContents ].
	changedFile := dummyRepository location / 'b.txt'.
	changedFile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out) nextPutAll: changedContents ].
	diffTool := dummyRepository diffTool.
	diffTool diffArgs: { originalFile basename . changedFile basename }.
	"when running git diff with 2 files the --exit-code option is automatically activated,
	so that exit value is 0 for equal files, 1 for different files, and >1 for errors"
	^ [ diffTool asUnifiedDiff ] 
		on: GtGitCliCommandError 
		do: [ :error | 
			error exitCode = 1 
				ifTrue: [ error resume ]
				ifFalse: [ error pass ] ]
]

{ #category : #operations }
PureGitDiffTool class >> gitDiffNoContextBetween: originalContents and: changedContents [
	| temporaryDirectory dummyRepository originalFile changedFile diffTool |
	temporaryDirectory := FileReference newTempFilePrefix: 'pure-git-diff-tool-' suffix: '-tmp'.
	dummyRepository := PureGitRepository on: temporaryDirectory.
	dummyRepository ensureLocation.
	originalFile := dummyRepository location / 'a.txt'.
	originalFile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out) nextPutAll: originalContents ].
	changedFile := dummyRepository location / 'b.txt'.
	changedFile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out) nextPutAll: changedContents ].
	diffTool := dummyRepository diffTool.
	diffTool diffArgs: { '--unified=0' . originalFile basename . changedFile basename }.
	"when running git diff with 2 files the --exit-code option is automatically activated,
	so that exit value is 0 for equal files, 1 for different files, and >1 for errors"
	^ [ diffTool asUnifiedDiff ] 
		on: GtGitCliCommandError 
		do: [ :error | 
			error exitCode = 1 
				ifTrue: [ error resume ]
				ifFalse: [ error pass ] ]
]

{ #category : #accessing }
PureGitDiffTool >> asText [
	^ String streamContents: [ :out |
		self diffLines do: [ :each |
			out nextPutAll: each; cr ] ]
]

{ #category : #accessing }
PureGitDiffTool >> asUnifiedDiff [
	^ UnifiedDiffCollection new readFromLines: self diffLines readStream
]

{ #category : #accessing }
PureGitDiffTool >> diff [
	^ self asUnifiedDiff
]

{ #category : #accessing }
PureGitDiffTool >> diffArgs [
	^ diffArgs
]

{ #category : #accessing }
PureGitDiffTool >> diffArgs: aCollection [
	diffArgs := aCollection
]

{ #category : #accessing }
PureGitDiffTool >> diffLines [
	^ self repository queries diff: { '--no-prefix' } , diffArgs
]

{ #category : #accessing }
PureGitDiffTool >> diffSummary [
	| numstat filesChangedCount additionsCount deletionsCount |
	numstat := self repository queries diff: { '--numstat' } , diffArgs.
	filesChangedCount := numstat size.
	filesChangedCount = 0 
		ifTrue: [ ^ 'no changes' ].
	numstat := numstat collect: [ :each | | elements |
		elements := Character tab split: each.
		Array 
			with: (Integer readFrom: elements first ifFail: [ 0 ])
			with: (Integer readFrom: elements second ifFail: [ 0 ]) ].
	additionsCount := numstat sumNumbers: #first.
	deletionsCount := numstat sumNumbers: #second.
	^ '{1} with {2} and {3}.' format: {
		filesChangedCount pluralize: 'changed file'. 
		additionsCount pluralize: 'addition'.
		deletionsCount pluralize: 'deletion' }
]
