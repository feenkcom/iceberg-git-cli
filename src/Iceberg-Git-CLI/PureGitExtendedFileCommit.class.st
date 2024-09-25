"
I wrap a file commit and add resolved changes to parents as well as author ownership.
"
Class {
	#name : #PureGitExtendedFileCommit,
	#superclass : #Object,
	#instVars : [
		'commit',
		'changesToParent',
		'authors',
		'lineCount',
		'changedLines'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitExtendedFileCommit >> author [
	^ commit author
]

{ #category : #accessing }
PureGitExtendedFileCommit >> authorTop3Description [
	| selection |
	selection := self authors associations sort: #value descending.
	selection := selection copyFrom: 1 to: (3 min: selection size).
	^ ', ' join: (selection collect: [ :each |
		'{1} ({2})' format: { each key. each value printShowingDecimalPlaces: 2 } ])
]

{ #category : #accessing }
PureGitExtendedFileCommit >> authors [
	^ authors ifNil: [ 
		authors := Dictionary new ]
]

{ #category : #accessing }
PureGitExtendedFileCommit >> changesToParent [
	^ changesToParent ifNil: [ 
		changesToParent := self commit changesToParent firstDiff ]
]

{ #category : #accessing }
PureGitExtendedFileCommit >> commit [
	^ commit
]

{ #category : #accessing }
PureGitExtendedFileCommit >> commit: aFileCommit [
	commit := aFileCommit
]

{ #category : #accessing }
PureGitExtendedFileCommit >> id [
	^ commit id
]

{ #category : #operations }
PureGitExtendedFileCommit >> initializeAsFirst [
	self numberOfLines: self numberOfLinesChanged.
	self authors at: self author put: 1.0
]

{ #category : #operations }
PureGitExtendedFileCommit >> initializeFromParent: parent [
	| reduction authorFraction |
	self numberOfLines: parent numberOfLines + self numberOfLinesChanged.
	reduction := parent numberOfLines / self numberOfLines.
	parent authors keysAndValuesDo: [ :author :fraction |
		self authors at: author put: fraction * reduction ].
	authorFraction := self authors at: self author ifAbsent: [ 0.0 ].
	self authors
		at: self author
		put: authorFraction + (self numberOfLinesChanged / self numberOfLines).
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLines [
	^ lineCount
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLines: count [
	lineCount := count
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLinesChanged [
	^ changedLines ifNil: [ 
		changedLines := self changesToParent numberOfLinesChanged ]
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLinesChangedDescription [
	^ (self numberOfLinesChanged signBit = 1 ifTrue: [ '-' ] ifFalse: [ '+' ])
		, self numberOfLinesChanged printString
]

{ #category : #accessing }
PureGitExtendedFileCommit >> path [
	^ commit path
]

{ #category : #printing }
PureGitExtendedFileCommit >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: self id.
	stream space.
	stream nextPutAll: self path.
	stream nextPut: $)
]

{ #category : #accessing }
PureGitExtendedFileCommit >> shortId [
	^ commit shortCommitId
]
