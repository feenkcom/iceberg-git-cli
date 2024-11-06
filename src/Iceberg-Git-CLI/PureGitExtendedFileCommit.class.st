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
		'changedLines',
		'addedLines',
		'removedLines',
		'modifiedLines'
	],
	#category : #'Iceberg-Git-CLI-Pure-Analysis'
}

{ #category : #accessing }
PureGitExtendedFileCommit >> author [
	^ commit author
]

{ #category : #accessing }
PureGitExtendedFileCommit >> authorTop3Description [
	| selection |
	selection := self sortedAuthors.
	selection := selection copyFrom: 1 to: (3 min: selection size).
	^ ', '
		join: (selection
				collect: [ :each | 
					'{1} {2}'
						format: {each key.
								each value printShowingDecimalPlaces: 2} ])
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
PureGitExtendedFileCommit >> changesToParent: aUnifiedDiff [
	changesToParent := aUnifiedDiff
]

{ #category : #accessing }
PureGitExtendedFileCommit >> comment [
	^ commit comment
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
	| authorFraction correction |
	self numberOfLines: parent numberOfLines + self numberOfLinesChanged.
	parent authors keysAndValuesDo: [ :author :fraction |
		correction := self numberOfLines - self numberOfLinesAdded.
		self numberOfLines > 0 
			ifTrue: [ correction := correction / self numberOfLines ].
		self authors 
			at: author 
			put: fraction * correction  ].
	authorFraction := self authors 
		at: self author ifAbsent: [ 0.0 ].
	correction := self numberOfLinesAdded.
	self numberOfLines > 0 
		ifTrue: [ correction := correction / self numberOfLines ].	
	self authors
		at: self author
		put: authorFraction + correction
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
PureGitExtendedFileCommit >> numberOfLinesAdded [
	^ addedLines ifNil: [ 
		addedLines := self changesToParent numberOfLinesAdded ]
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLinesChanged [
	^ changedLines ifNil: [ 
		changedLines := self changesToParent numberOfLinesChanged ]
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLinesChangedDescription [
	^ (self numberOfLinesChanged signBit = 1 ifTrue: [ '-' ] ifFalse: [ '+' ])
		, self numberOfLinesChanged abs printString
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLinesModified [
	^ modifiedLines ifNil: [ 
		modifiedLines := self changesToParent numberOfLinesModified ]
]

{ #category : #accessing }
PureGitExtendedFileCommit >> numberOfLinesRemoved [
	^ removedLines ifNil: [ 
		removedLines := self changesToParent numberOfLinesRemoved ]
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

{ #category : #accessing }
PureGitExtendedFileCommit >> sortedAuthors [
	^ self authors associations sort: #value descending
]

{ #category : #accessing }
PureGitExtendedFileCommit >> timestamp [
	^ commit timestamp
]
