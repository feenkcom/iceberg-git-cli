"
I am a collection of PureGitExtendedFileCommits, the result of an analysis of the historic evolution of one file.
"
Class {
	#name : #PureGitTrackedFile,
	#superclass : #Object,
	#instVars : [
		'file',
		'extendedCommits',
		'versions'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #operations }
PureGitTrackedFile >> analyze [
	self computeOwnership.
	self computeVersions
]

{ #category : #accessing }
PureGitTrackedFile >> authorOfTrackedLine: trackedLine [
	| firstAppearance |
	firstAppearance := trackedLine positionsInVersions findFirst: [ :position | position isZero not ].
	^ firstAppearance isZero
		ifTrue: [ 'not found' ]
		ifFalse: [ (self commits at: firstAppearance) author ]
]

{ #category : #accessing }
PureGitTrackedFile >> commits [
	^ extendedCommits
		ifNil: [ extendedCommits := self file logPatchReverse toArray wait ]
]

{ #category : #operations }
PureGitTrackedFile >> computeOwnership [
	| previous |
	self commits do: [ :each | 
		previous
			ifNil: [ each initializeAsFirst ]
			ifNotNil: [ each initializeFromParent: previous ].
		previous := each ]
]

{ #category : #operations }
PureGitTrackedFile >> computeVersions [
	| previous count |
	previous := nil.
	count := self commits size.
	versions := OrderedCollection new.
	self commits
		doWithIndex: [ :commit :rank | 
			| newContents line |
			rank = 1
				ifTrue: [ newContents := commit changesToParent applyToLines: #().
					previous := newContents
							collectWithIndex: [ :each :index | 
								PureGitTrackedLine new
									line: each;
									initializeForNumberOfVersions: count;
									positionInVersionAt: rank put: index;
									yourself ] ]
				ifFalse: [ | oldLineNumber newLineNumber |
					oldLineNumber := newLineNumber := 1.
					newContents := Array
							streamContents: [ :out | 
								commit changesToParent changeChunks
									do: [ :changeChunk | 
										[ oldLineNumber < changeChunk effectiveOldStart ]
											whileTrue: [ line := previous at: oldLineNumber.
												line positionInVersionAt: rank put: newLineNumber.
												out nextPut: line.
												oldLineNumber := oldLineNumber + 1.
												newLineNumber := newLineNumber + 1 ].
										changeChunk newContentsLines
											do: [ :newLine | 
												line := PureGitTrackedLine new
														line: newLine allButFirst;
														initializeForNumberOfVersions: count;
														positionInVersionAt: rank put: newLineNumber;
														yourself.
												out nextPut: line.
												newLineNumber := newLineNumber + 1 ].
										oldLineNumber := oldLineNumber + changeChunk oldCount ].
								[ oldLineNumber <= previous size ]
									whileTrue: [ line := previous at: oldLineNumber.
										line positionInVersionAt: rank put: newLineNumber.
										out nextPut: line.
										oldLineNumber := oldLineNumber + 1.
										newLineNumber := newLineNumber + 1 ] ].
					previous := newContents ].
			versions
				add: (PureGitTrackedFileVersion new
						trackedFile: self;
						commit: commit;
						versionNumber: rank;
						lines: previous) ].
	^ versions
]

{ #category : #accessing }
PureGitTrackedFile >> file [
	^ file
]

{ #category : #accessing }
PureGitTrackedFile >> file: aGitFile [
	file := aGitFile
]

{ #category : #'as yet unclassified' }
PureGitTrackedFile >> maxLinesCount [
	^ self versions max: [:each | each lines size]
]

{ #category : #accessing }
PureGitTrackedFile >> path [
	^ self file path
]

{ #category : #printing }
PureGitTrackedFile >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: self path.
	stream nextPut: $)
]

{ #category : #accessing }
PureGitTrackedFile >> uniqueTrackedLines [
	| trackedLines |
	trackedLines := IdentitySet new.
	self versions do: [ :each |
		trackedLines addAll: each lines ].
	^ trackedLines
]

{ #category : #accessing }
PureGitTrackedFile >> versions [
	^ versions
]
