"
I model a git repository that exists at a specific location.

I use a git command line interface to interact with my on disk repository.

I do not know anything about Iceberg or Pharo code, I only deal with files.
"
Class {
	#name : #PureGitRepository,
	#superclass : #Object,
	#instVars : [
		'location',
		'exists',
		'hasHead'
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
PureGitRepository >> allAnnotatedCommits [
	| commitsMap annotatedCommits |
	annotatedCommits := self allCommits collect: [ :each |
		PureGitAnnotatedCommit new
			commit: each;
			yourself ].
	commitsMap := Dictionary new: annotatedCommits size.
	annotatedCommits do: [ :each | 
		commitsMap at: each id put: each ].
	annotatedCommits do: [ :annotatedCommit |
		annotatedCommit parents: (annotatedCommit parentIds collect: [ :id | commitsMap at: id ]) ].
	self tags do: [ :tag |
		commitsMap 
			at: tag commitId 
			ifPresent: [ :annotatedCommit | annotatedCommit addLabel: tag name ] ].
	self allBranches do: [ :branch |
		commitsMap 
			at: branch commitId 
			ifPresent: [ :annotatedCommit | annotatedCommit addLabel: branch name ] ].
	^ annotatedCommits
]

{ #category : #accessing }
PureGitRepository >> allBranches [
	^ self localBranches , self remoteBranches
]

{ #category : #accessing }
PureGitRepository >> allCommits [
	| output commitLines commits |
	self exists ifFalse: [ ^ #() ].
	output := self runGitWithArgs: { 
		'log'.
		self commitLineFormat , '%n@@@'.
		'--all'.
		'--remotes' }.
	commitLines := output splitOn: [ :each | each = '@@@' ].
	commitLines removeLast.
	commits := commitLines collect: [ :each | self commitFromLines: each ].
	^ commits sort: #timestamp descending
]

{ #category : #operations }
PureGitRepository >> clone: gitUrl [
	self runGitWithArgs: { 'clone' . gitUrl . '.' }
]

{ #category : #private }
PureGitRepository >> commitFromLines: lines [
	| author timestamp message id parents tree start stop |
	id := lines first.
	author := lines second.
	timestamp := ZTimestamp fromUnixTime: lines third asInteger.
	parents := lines fourth 
			ifEmpty: [ #() ] 
			ifNotEmpty: [ :line | line splitOn: ' ' ].
	tree := lines fifth.
	start := 7.
	stop := lines size.
	[ (lines at: start) isEmpty and: [ start <= stop ] ]
		whileTrue: [ start := start + 1 ].
	[ (lines at: stop) isEmpty and: [ start <= stop ] ]
		whileTrue: [ stop := stop - 1 ].
	message := String cr join: (lines copyFrom: start to: stop).
	^ (PureGitCommit inRepository: self)
		id: id;
		author: author;
		timestamp: timestamp;
		parentIds: parents;
		treeId: tree;
		comment: message;
		yourself
]

{ #category : #private }
PureGitRepository >> commitLineFormat [
	^ '--format=%H%n%an%n%at%n%P%n%T%n%n%B'
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
	^ exists 
		or: [ exists := location notNil and: [ (location / '.git') exists ] ]
]

{ #category : #testing }
PureGitRepository >> hasHead [
	^ hasHead
		or: [ hasHead := self exists
					and: [ [ (self runGitWithArgs: #('show-ref' '--head' '-d' 'HEAD')) notEmpty ]
							on: GtGitCliCommandError
							do: [ false ] ] ]
]

{ #category : #accessing }
PureGitRepository >> head [
	^ self resolveCommit: 'HEAD'
]

{ #category : #operations }
PureGitRepository >> init [
	self runGitWithArgs: { 'init' }
]

{ #category : #initialization }
PureGitRepository >> initialize [
	super initialize.
	exists := false.
	hasHead := false.
]

{ #category : #accessing }
PureGitRepository >> localBranches [
	| output |
	self exists ifFalse: [ ^ #() ].
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
	self hasHead ifFalse: [ ^ #() ].
	^ self head log
]

{ #category : #accessing }
PureGitRepository >> logFrom: start [
	| output commitLines |
	output := self runGitWithArgs: { 
		'log'.
		self commitLineFormat , '%n@@@'.
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
	self exists ifFalse: [ ^ #() ].
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
PureGitRepository >> resolveBlob: blobId [
	^ (PureGitBlob inRepository: self)
		id: blobId;
		yourself
]

{ #category : #accessing }
PureGitRepository >> resolveCommit: commitId [
	| output |
	output := self runGitWithArgs: {
		'show'.
		'--no-patch'.
		self commitLineFormat.
		commitId }.
	^ self commitFromLines: output
]

{ #category : #accessing }
PureGitRepository >> resolveTree: treeId [
	^ (PureGitTree inRepository: self)
		id: treeId;
		yourself
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
PureGitRepository >> status [
	| lines |
	self exists ifFalse: [ ^ #() ].
	lines := self runGitWithArgs: { 'status' . '--porcelain' }.
	^ lines collect: [ :each |
		(PureGitFileStatus inRepository: self)
			fromLine: each ]
]

{ #category : #accessing }
PureGitRepository >> tags [
	| output |
	self exists ifFalse: [ ^ #() ].
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

{ #category : #accessing }
PureGitRepository >> treeEntriesFor: treeId [
	| lines |
	lines := self runGitWithArgs:  { 'ls-tree' . treeId }.
	^ lines collect: [ :line | | firstTab meta name |
		firstTab := line indexOf: Character tab.
		meta := Character space split: (line copyFrom: 1 to: firstTab - 1).
		name := line copyFrom: firstTab + 1 to: line size.
		(PureGitTreeEntry inRepository: self)
			name: name;
			mode: (Integer readFrom: meta first base: 8);
			type: meta second asSymbol;
			id: meta third;
			yourself ]
]
