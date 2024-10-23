"
I run queries on a repository that do not change its state
"
Class {
	#name : #PureGitQueries,
	#superclass : #PureGitCommandLineInterface,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #queries }
PureGitQueries >> allAnnotatedCommits [
	| commitsMap annotatedCommits |
	annotatedCommits := self allCommits toArray wait collect: [ :each |
		PureGitAnnotatedCommit new
			commit: each;
			yourself ].
	commitsMap := Dictionary new: annotatedCommits size.
	annotatedCommits do: [ :each | 
		commitsMap at: each id put: each ].
	annotatedCommits do: [ :annotatedCommit |
		annotatedCommit parents: (annotatedCommit parentIds collect: [ :id | commitsMap at: id ]) ].
	self tags toArray wait do: [ :tag |
		commitsMap 
			at: tag commitId 
			ifPresent: [ :annotatedCommit | annotatedCommit addLabel: tag name ] ].
	self allBranches do: [ :branch |
		commitsMap 
			at: branch commitId 
			ifPresent: [ :annotatedCommit | annotatedCommit addLabel: branch name ] ].
	^ annotatedCommits
]

{ #category : #convenience }
PureGitQueries >> allBranches [
	^ self localBranches , self remoteBranches
]

{ #category : #queries }
PureGitQueries >> allCommits [
	| output commitLines |
	self repository exists ifFalse: [ ^ #() asAsyncStream ].
	output := self runGitWithArgsAsync: { 
		'log'.
		self commitLineFormat , '%n@@@'.
		'--all'.
		'--date-order' }.
	commitLines := output splitOn: [ :each | each = '@@@' ].
	commitLines := commitLines select: [ :lines | lines notEmpty ].
	^ commitLines collect: [ :each | self commitFromLines: each ]
]

{ #category : #queries }
PureGitQueries >> blame: path [
	| lines commitsCache |
	lines := self runGitWithArgsAsync: { 'blame' . '-s' . '-l' . path }.
	commitsCache := Dictionary new.
	^ lines collect: [ :each | 
		| space closingParenthesis commit lineNumber line blameLine|
		space := each indexOf: $ .
		commit := each copyFrom: 1 to: space - 1.
		commit first = $^ ifTrue: [ commit := commit allButFirst ].
		closingParenthesis := each indexOf: $) startingAt: space + 1.
		lineNumber := (each copyFrom: space + 1 to: closingParenthesis  - 1) asInteger.
		line := each copyFrom: closingParenthesis + 2 to: each size.
		(blameLine := PureGitBlameLine new)
			commit: commit;
			line: line;
			lineNumber: lineNumber;
			path: path.
		blameLine resolveCommitIn: self using: commitsCache.
		blameLine ]
]

{ #category : #convenience }
PureGitQueries >> branch [
	| currentBranchName |
	currentBranchName := self currentBranchName.
	^ self localBranches
		detect: [ :each | each name = currentBranchName ]
		ifNone: [ nil ]
]

{ #category : #private }
PureGitQueries >> commitFromLines: lines [
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
	[ (lines at: start) isEmpty and: [ start < stop ] ]
		whileTrue: [ start := start + 1 ].
	[ (lines at: stop) isEmpty and: [ start <= stop ] ]
		whileTrue: [ stop := stop - 1 ].
	message := String cr join: (lines copyFrom: start to: stop).
	^ (PureGitCommit inRepository: self repository)
		id: id;
		author: author;
		timestamp: timestamp;
		parentIds: parents;
		treeId: tree;
		comment: message;
		yourself
]

{ #category : #private }
PureGitQueries >> commitLineFormat [
	^ '--format=%H%n%an%n%at%n%P%n%T%n%n%B'
]

{ #category : #queries }
PureGitQueries >> configAt: optionName ifAbsent: block [
	| result missing|
	missing := '__missing_value__'.
	result := self runGitWithArgs: { 'config' . '--default' . missing . optionName }.
	^ (result isEmpty or: [ result first = missing ])
		ifTrue: block 
		ifFalse: [ result first ]
]

{ #category : #queries }
PureGitQueries >> contentsOfBlob: aHash [
	^ self executor 
		runGitRawWithArgs: { 'cat-file' . 'blob'. aHash }
		for: #contentsOfFile:
]

{ #category : #queries }
PureGitQueries >> currentBranchName [
	| output |
	self repository exists ifFalse: [ ^ '' ].
	output := self runGitWithArgs: #( 'branch' '--show-current' ).
	^ output isEmpty ifTrue: [ '' ] ifFalse: [ output first ]
]

{ #category : #queries }
PureGitQueries >> diff: args [
	^ self runGitWithArgs: #('diff') , args
]

{ #category : #convenience }
PureGitQueries >> head [
	^ self resolveCommit: 'HEAD'
]

{ #category : #convenience }
PureGitQueries >> initialDefaultBranchName [
	"Return the default branch name used when initializing a new repository.
	Consult the init.defaultbranch git config option and fall back to our superclass' implementation."

	^ self configAt: 'init.defaultbranch' ifAbsent: [ 'master' ]
]

{ #category : #queries }
PureGitQueries >> internals [
	| config lines counts values |
	lines := self runGitWithArgs: #('config' '--list').
	values := lines collect: [ :line | $= split: line ].
	values sort: #first ascending.
	config := values
			collect: [ :each | each first -> each second ]
			as: OrderedDictionary.
	self repository exists 
		ifTrue: [
			lines := self runGitWithArgs: #('count-objects' '-v').
			values := lines collect: [ :line | $: split: line ].
			counts := values
					collect: [ :each | each first -> each second trimBoth asNumber ]
					as: OrderedDictionary]
		ifFalse: [ counts := nil ].
	^ {
		#'git-config' -> config.
		#'git-count-objects' -> counts } as: OrderedDictionary
]

{ #category : #queries }
PureGitQueries >> localBranches [
	| output |
	self repository exists ifFalse: [ ^ #() ].
	output := self runGitWithArgs: {
		'branch'.
		'--format=%(objectname) %(refname:short)' }.
	^ output
		collect: [ :each | 
			| firstSpace |
			firstSpace := each indexOf: Character space.
			(PureGitLocalBranch inRepository: self repository)
				commit: (each copyFrom: 1 to: firstSpace - 1);
				name: (each copyFrom: firstSpace + 1 to: each size);
				yourself ]
]

{ #category : #convenience }
PureGitQueries >> log [
	self repository hasHead ifFalse: [ ^ #() asAsyncStream ].
	^ self head log
]

{ #category : #queries }
PureGitQueries >> log: args [
	| output commitLines  |
	output := self runGitWithArgsAsync: { 
		'log'.
		self commitLineFormat , '%n@@@' 
		} , args.
	commitLines := output splitOn: [ :each | each = '@@@' ].
	commitLines := commitLines select: [ :lines | lines notEmpty ].
	^ commitLines collect: [ :each | self commitFromLines: each ]
]

{ #category : #queries }
PureGitQueries >> remoteBranches [
	| output |
	self repository exists ifFalse: [ ^ #() ].
	output := self runGitWithArgs: {
		'branch'.
		'--remote'.
		'--format=%(objectname) %(refname:short)' }.
	^ output
		collect: [ :each | 
			| firstSpace |
			firstSpace := each indexOf: Character space.
			(PureGitRemoteBranch inRepository: self repository)
				commit: (each copyFrom: 1 to: firstSpace - 1);
				name: (each copyFrom: firstSpace + 1 to: each size);
				yourself ]
]

{ #category : #queries }
PureGitQueries >> remotes [
	self repository exists ifFalse: [ ^ #() ].
	^ (self runGitWithArgs: #( 'remote' )) collect: [ :each | | url |
		url := (self runGitWithArgs: { 'remote' . 'get-url' . each }) first.
		(PureGitRemote inRepository: self repository)
			name: each;
			url: url;
			yourself ]
]

{ #category : #convenience }
PureGitQueries >> resolveBranchOrTag: aName [
	^ self allBranches
		detect: [ :each | each name = aName ]
		ifNone: [ self tags toArray wait
				detect: [ :each | each name = aName ]
				ifNone: [ aName ] ]
]

{ #category : #queries }
PureGitQueries >> resolveCommit: commitId [
	| output |
	output := self runGitWithArgs: {
		'show'.
		'--no-patch'.
		self commitLineFormat.
		commitId }.
	^ self commitFromLines: output
]

{ #category : #queries }
PureGitQueries >> resolveHead [
	^ self runGitWithArgs: #('show-ref' '--head' '-d' 'HEAD')
]

{ #category : #queries }
PureGitQueries >> sizeOfBlob: aHash [
	^ (self executor 
		runGitWithArgs: { 'cat-file' . '-s'. aHash }
		for: #sizeOfFile:) first asInteger
]

{ #category : #convenience }
PureGitQueries >> stagedChanges [
	^ self repository diffTool
		diffArgs: { '--staged' };
		diff
]

{ #category : #convenience }
PureGitQueries >> status [
	^ self statusFor: nil
]

{ #category : #queries }
PureGitQueries >> statusFor: path [
	| lines args |
	self repository exists ifFalse: [ ^ #() ].
	args := { 'status' . '--porcelain' }.
	path ifNotNil: [ args := args copyWith: path ].
	lines := self runGitWithArgs: args.
	^ lines collect: [ :each |
		(PureGitFileStatus inRepository: self repository)
			fromLine: each ]
]

{ #category : #queries }
PureGitQueries >> tags [
	| output |
	self repository exists ifFalse: [ ^ #() asAsyncStream ].
	output := self runGitWithArgsAsync: {
		'tag'.
		'--format=%(objectname) %(refname:short)' }.
	^ output
		collect: [ :each | 
			| firstSpace |
			firstSpace := each indexOf: Character space.
			(PureGitTag inRepository: self repository)
				commit: (each copyFrom: 1 to: firstSpace - 1);
				name: (each copyFrom: firstSpace + 1 to: each size);
				yourself ]
]

{ #category : #queries }
PureGitQueries >> treeEntriesFor: treeId [
	| lines |
	lines := self runGitWithArgs:  { 'ls-tree' . treeId }.
	^ lines collect: [ :line | | firstTab meta name |
		firstTab := line indexOf: Character tab.
		meta := Character space split: (line copyFrom: 1 to: firstTab - 1).
		name := line copyFrom: firstTab + 1 to: line size.
		(PureGitTreeEntry inRepository: self repository)
			name: name;
			mode: (Integer readFrom: meta first base: 8);
			type: meta second asSymbol;
			id: meta third;
			yourself ]
]

{ #category : #convenience }
PureGitQueries >> unstagedChanges [
	^ self repository diffTool
		diffArgs: { };
		diff
]

{ #category : #queries }
PureGitQueries >> upstreamNameForBranch: localBranchName [
	| result |
	result := self runGitWithArgs: {
			'branch'.
			'--list'.
			'--format=%(upstream:short)'.
			localBranchName }.
	^ result isEmpty ifTrue: [ nil ] ifFalse: [ result first ]
]
