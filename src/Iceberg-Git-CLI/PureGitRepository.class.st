Class {
	#name : #PureGitRepository,
	#superclass : #Object,
	#instVars : [
		'location'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #'instance creation' }
PureGitRepository class >> on: aFileReference [
	^ self new
		location: aFileReference;
		yourself
]

{ #category : #accessing }
PureGitRepository >> allBranches [
	^ self localBranches , self remoteBranches
]

{ #category : #accessing }
PureGitRepository >> allCommits [
	| output commitLines commits |
	output := self runGitWithArgs: { 
		'log'.
		'--format=%H%n%an%n%at%n%P%n%n%B%n@@@'.
		'--all'.
		'--remotes' }.
	commitLines := output splitOn: [ :each | each = '@@@' ].
	commitLines removeLast.
	commits := commitLines collect: [ :each | self commitFromLines: each ].
	^ commits sort: #timestamp descending
]

{ #category : #private }
PureGitRepository >> commitFromLines: lines [
	| author timestamp message id parents |
	id := lines at: 1.
	author := lines at: 2.
	timestamp := ZTimestamp fromUnixTime: (lines at: 3) asInteger.
	parents := (lines at: 4) 
			ifEmpty: [ #() ] 
			ifNotEmpty: [ :line | line splitOn: ' ' ].
	message := String streamContents: [ :str | 
			6 to: lines size do: [ :i | 
				str nextPutAll: (lines at: i); cr ] ].
	^ (PureGitCommit inRepository: self)
		id: id;
		author: author;
		timestamp: timestamp;
		parentIds: parents;
		comment: message;
		yourself
]

{ #category : #accessing }
PureGitRepository >> contentsOfBlob: aHash [
	| executor |
	executor := IceGitCliPlatform current executor.
	executor workingDirectory: self ensureLocation.
	^ executor 
		runGitRawWithArgs: { 'cat-file' . 'blob'. aHash }
		for: #contentsOfFile:
]

{ #category : #private }
PureGitRepository >> ensureLocation [
	(location notNil and: [ location exists not ])
		ifTrue: [ location ensureCreateDirectory ].
	^ location
]

{ #category : #testing }
PureGitRepository >> exists [
	^ location notNil and: [ (location / '.git') exists ]
]

{ #category : #accessing }
PureGitRepository >> head [
	^ self resolveCommit: 'HEAD'
]

{ #category : #accessing }
PureGitRepository >> localBranches [
	| output |
	output := self runGitWithArgs: {
		'branch'.
		'--format=%(objectname) %(refname:short)' }.
	^ output
		collect: [ :each | 
			| firstSpace |
			firstSpace := each indexOf: Character space.
			(PureGitLocalBranch inRepository: self)
				commit: (each copyFrom: 1 to: firstSpace - 1);
				name: (each copyFrom: firstSpace + 1 to: each size);
				yourself ]
]

{ #category : #accessing }
PureGitRepository >> location [
	^ location
]

{ #category : #accessing }
PureGitRepository >> location: aFileReference [
	location := aFileReference
]

{ #category : #accessing }
PureGitRepository >> log [
	^ self head log
]

{ #category : #accessing }
PureGitRepository >> logFrom: start [
	| output commitLines |
	output := self runGitWithArgs: { 
		'log'.
		'--format=%H%n%an%n%at%n%P%n%n%B%n@@@'.
		start }.
	commitLines := output splitOn: [ :each | each = '@@@' ].
	commitLines removeLast.
	^ commitLines collect: [ :each | self commitFromLines: each ]
]

{ #category : #printing }
PureGitRepository >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	location ifNotNil: [ location printOn: stream ].
	stream nextPut: $)
]

{ #category : #accessing }
PureGitRepository >> remoteBranches [
	| output |
	output := self runGitWithArgs: {
		'branch'.
		'--remote'.
		'--format=%(objectname) %(refname:short)' }.
	^ output
		collect: [ :each | 
			| firstSpace |
			firstSpace := each indexOf: Character space.
			(PureGitRemoteBranch inRepository: self)
				commit: (each copyFrom: 1 to: firstSpace - 1);
				name: (each copyFrom: firstSpace + 1 to: each size);
				yourself ]
]

{ #category : #accessing }
PureGitRepository >> resolveCommit: commitId [
	| output |
	output := self runGitWithArgs: {
		'show'.
		'--no-patch'.
		'--format=%H%n%an%n%at%n%P%n%n%B'.
		commitId }.
	^ self commitFromLines: output
]

{ #category : #private }
PureGitRepository >> runGitWithArgs: args [
	"Run CLI git with the passed arguments and return the lines from standard output.
	Wait for the git command to complete. Signal an error when not successful."

	| operation executor |
	operation := thisContext sender method selector.
	executor := IceGitCliPlatform current executor.
	executor workingDirectory: self ensureLocation.
	^ executor runGitWithArgs: args for: operation
]

{ #category : #accessing }
PureGitRepository >> tags [
	| output |
	output := self runGitWithArgs: {
		'tag'.
		'--format=%(objectname) %(refname:short)' }.
	^ output
		collect: [ :each | 
			| firstSpace |
			firstSpace := each indexOf: Character space.
			(PureGitTag inRepository: self)
				commit: (each copyFrom: 1 to: firstSpace - 1);
				name: (each copyFrom: firstSpace + 1 to: each size);
				yourself ]
]
