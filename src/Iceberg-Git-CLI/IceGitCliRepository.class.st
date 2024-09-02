"
Implements the same API as IceLibgitRepository only using the git cli command. Requires a git executable in the path.
"
Class {
	#name : #IceGitCliRepository,
	#superclass : #IceRepository,
	#instVars : [
		'location',
		'head',
		'remoteMap',
		'revListMap',
		'commitMap'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #accessing }
IceGitCliRepository class >> creatorClass [
	^ GtIceRepositoryCreator
]

{ #category : #'instance creation' }
IceGitCliRepository class >> fromLibGitRepository: existingRepository [
	"Create a new repository based on an existing repository
	from which the location, name and reference commit are used"

	| newRepository |
	newRepository := self new
			location: existingRepository location;
			name: existingRepository name.
	existingRepository isMissing ifTrue: [ ^ newRepository ].
	newRepository workingCopy
		referenceCommit: (newRepository commitFromGitCommit: existingRepository workingCopy referenceCommit id).
	newRepository workingCopy initializePackagesFromRepository.
	^ newRepository
]

{ #category : #'instance creation' }
IceGitCliRepository class >> on: aFileReference [
	"Create a new repository on a directory location"

	^ self new
		location: aFileReference;
		yourself
]

{ #category : #'API - files' }
IceGitCliRepository >> addFileToIndex: aFile [
	
	self addFilesToIndex: { aFile }
]

{ #category : #'API - files' }
IceGitCliRepository >> addFilesToIndex: aCollection [
	| args |
	args := { 'add' } asOrderedCollection.
	args
		addAll: (aCollection
				collect: [ :each | 
					self assert: each asFileReference isRelative.
					each asFileReference path pathString ]).
	self runGitWithArgs: args
]

{ #category : #accessing }
IceGitCliRepository >> addRemote: remoteName url: url [
	self
		runGitWithArgs: {'remote'.
				'add'.
				remoteName.
				url}
]

{ #category : #'API - branches' }
IceGitCliRepository >> allBranches [
	^ self localBranches , self remoteTrackedBranches
]

{ #category : #'API - branches' }
IceGitCliRepository >> allCommits [
	| lines commitLines commits |
	lines := self
			runGitWithArgs: {'log'.
					'-s'.
					'--format=format:%H%n%an%n%at%n%P%n%n%B%n@@@'.
					'--all'.
					'--remotes'}.
	commitLines := lines splitOn: [ :each | each = '@@@' ].
	commitLines removeLast.
	commits := commitLines collect: [ :each | self iceGitCommitFromLines: each ].
	commits do: [:each | commitMap at: each id put: each].
	^ commits asSortedCollection: [:a :b | a datetime > b datetime]
]

{ #category : #'API - accessing' }
IceGitCliRepository >> basicCodeDirectory [
	^ self subdirectory isEmptyOrNil
		ifTrue: [ self repositoryDirectory ]
		ifFalse: [ self repositoryDirectory / self subdirectory ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> basicNewBranchNamed: aString [ 

	^ IceGitCliLocalBranch named: aString inRepository: self
]

{ #category : #'API - branches' }
IceGitCliRepository >> basicNewRemoteBranchNamed: aString [ 

	^ IceGitCliRemoteBranch named: aString inRepository: self
]

{ #category : #'API - branches' }
IceGitCliRepository >> branchNamed: aString ifPresent: presentBlock ifAbsent: absentBlock [
	| found |
	found := self lookupLocalBranch: aString ifAbsent: [ nil ].
	^ found
		ifNil: absentBlock
		ifNotNil: [ presentBlock value: (self basicNewBranchNamed: aString) ]
]

{ #category : #'private - changes' }
IceGitCliRepository >> changedFilesBetween: aCommitish and: otherCommitish [
	"Answer a list of files that changed between two commits"

	^ self runGitWithArgs: {
		'diff'.
		'--name-only'.
		aCommitish id.
		otherCommitish id }
]

{ #category : #'API - registry' }
IceGitCliRepository >> checkForRegistryConflicts [
	
	"If the repository has no location, do not check for conflicts."
	self location ifNil: [ ^ self ].
	
	self class registry 
		detect: [ :repo | repo location = self location ]
		ifFound: [ :repo | self origin = repo origin
			ifTrue: [ 
				IceDuplicatedRepository signal: 
					('You already have an Iceberg repository 
at {1} 
and with the same origin URL. 

If you really whant create another one, 
please locate it in a different directory.'
					 format: {self location pathString}) ]
			ifFalse: [
				IceDuplicatedRepository signal: 
					('You already have an Iceberg repository at 
{1} 
but with a different origin URL.

You provided {2} 
and the original repository''s url is {3}.'
					 format: {self location. self origin. repo origin}) ]].
]

{ #category : #accessing }
IceGitCliRepository >> clearCaches [
	head := nil.
]

{ #category : #accessing }
IceGitCliRepository >> clearCommitMap [
	"Mainly for profiling. Should not normally need to be cleared"
	commitMap := Dictionary new.
]

{ #category : #actions }
IceGitCliRepository >> clone: aString [
	self runGitWithArgs: {
		'clone'.
		aString . 
		'.' }
]

{ #category : #'API - accessing' }
IceGitCliRepository >> codeDirectory [
	"Code repository might have been deleted or image might have been moved."
	self repositoryDirectory exists
		ifTrue: [ ^ self basicCodeDirectory ]
		ifFalse: [ IceLocalRepositoryMissing signalFor: self ]
]

{ #category : #'private - commits' }
IceGitCliRepository >> commitFromGitCommit: commitIdString [
	| lines |
	^ commitMap
		at: commitIdString
		ifAbsentPut: [ lines := self
					runGitWithArgs: {'show'.
							'-s'.
							'--format=tformat:%H%n%an%n%at%n%P%n%n%B'.
							commitIdString}.
			self iceGitCommitFromLines: lines ]
]

{ #category : #'API - accessing' }
IceGitCliRepository >> commitishNamed: aName [
	"Resolve a name in the form of:
	  - a commit hash
	  - a branch name
	  - some other expression such as HEAD or master~1
	and return the corresponding iceberg object for it."

	^ self
		branchNamed: aName
		ifAbsent: [
			self
				remoteBranchNamed: aName
				ifPresent: [ :found | ^ found ]
				ifAbsent: [ self revparse: aName ] ]
]

{ #category : #'private - commits' }
IceGitCliRepository >> commitsFromIds: idCollection [
	| lines commitLines range commits |
	idCollection isEmpty ifTrue: [ ^ #() ].
	range := idCollection size = 1
			ifTrue: [ idCollection first ]
			ifFalse: [ idCollection last , '..' , idCollection first ].
	lines := self runGitWithArgs: {
		'show'.
		'-s'.
		'--format=format:%H%n%an%n%at%n%P%n%n%B%n@@@'.
		range }.
	commitLines := lines splitOn: [ :each | each = '@@@' ].
	commitLines removeLast.
	commits := commitLines collect: [ :each | self iceGitCommitFromLines: each ].
	"the last commit from the range query above is not resolved, fetch it individually"
	idCollection size > 1
		ifTrue: [ commits := commits , (self commitsFromIds: { idCollection last }) ].
	^ commits
]

{ #category : #'API - accessing' }
IceGitCliRepository >> config [
	"Return a dictionary of the config values applicable to me"
	| lines values |
	lines := self runGitWithArgs: #('config' '--list').
	values := lines collect: [ :line | $= split: line ].
	values sort: #first ascending.
	^ values 
		collect: [ :each | each first -> each second ] 
		as: OrderedDictionary
]

{ #category : #accessing }
IceGitCliRepository >> configureUpstreamIfNecessary [
	| aRemote |
	self branch isUnbornBranch ifTrue: [ ^ self ].
	self branch hasUpstream ifTrue: [ ^ self ].

	aRemote := self remoteNamed: 'origin'.

	self pushBranch: self branch name to: aRemote name
]

{ #category : #accessing }
IceGitCliRepository >> contentsOfFile: aHash [
	| processBuilder result output args |
	args := { 'cat-file' . 'blob'. aHash }.
	self logStarted: #contentsOfFile: args: args.
	processBuilder := self git args: args.
	output := self waitForProcessAsync: processBuilder.
	output status isSuccess 
		ifFalse: [
			result := output stderr lines.
			self logEnded: #contentsOfFile: args: args output: result.
			^ GtGitCliCommandError new
				args: args;
				stderr: result;
				exitCode: output status code;
				signal ].
	result := output stdoutBytes.
	self logEnded: #contentsOfFile: args: args output: { result size asString , ' bytes' }.
	^ result
]

{ #category : #'API - branches' }
IceGitCliRepository >> createBranch: branchName inCommit: anIceGitCommit [
	"Creates a new branch from a given commit and switch to it"
	
	self runGitWithArgs: { 'branch' . branchName . anIceGitCommit gitRef }.
	
	^ (self branchNamed: branchName)
			switch;
			yourself
]

{ #category : #private }
IceGitCliRepository >> deltaTypeEnumFrom: statusChar [
	| flagMap |
	flagMap := { 
		$M -> 3.
		$T -> 8.
		$A -> 1.
		$D -> 2.
		$R -> 4.
		$C -> 5.
		$? -> 7.
		$! -> 6 } asDictionary.
	^ LGitDeltaTypeEnum basicNew value: (flagMap at: statusChar)
]

{ #category : #accessing }
IceGitCliRepository >> directoryNameForPackage: package [

	^ (self writerClass 
		directoryNameFor: package)
		asString
]

{ #category : #accessing }
IceGitCliRepository >> directoryPathStringForPackage: aMCPackage [ 

	^ self subdirectory isEmptyOrNil 
		ifTrue: [ self directoryNameForPackage: aMCPackage ]
		ifFalse: [ self subdirectory, '/',  (self directoryNameForPackage: aMCPackage) ]
]

{ #category : #'API - remotes' }
IceGitCliRepository >> fetch [
	"Fetch all commits and branches from all remotes"

	location isNil ifTrue: [ ^ self ].

	self
		runGitWithArgs: {'fetch'.
				'--all'}
]

{ #category : #accessing }
IceGitCliRepository >> fetchBranch: aBranch fromRemote: aRemote [
	self runGitWithArgs: {'fetch'.
		aRemote name.
		aBranch name }
]

{ #category : #'API - accessing' }
IceGitCliRepository >> getDeltasForFullDiff [
	"Return the deltas including untracked files.
	This makes it possible to create a full diff of what changed."

	| lines |
	lines := self
			runGitWithArgs: {'status'.
					'--porcelain'.
					'--untracked-files=all'}.
	^ lines collect: [ :line | GtGitDelta fromStatusLine: line in: self ]
]

{ #category : #'API - accessing' }
IceGitCliRepository >> getStatusByFile [
	| result lines |
	result := Dictionary new.
	lines := self runGitWithArgs: {
		'status'.
		'--porcelain' }.
	lines
		do: [ :each | 
			| statusChar path |
			statusChar := each trimLeft first.
			path := each copyFrom: 4 to: each size.
			result at: path put: (self statusEnumFrom: statusChar) ].
	^ result
]

{ #category : #accessing }
IceGitCliRepository >> gitVersion [
	<gtExample>
	<noTest>
	
	^ IceGitCliPlatform current executor gitVersion
]

{ #category : #accessing }
IceGitCliRepository >> handleLibgitError: aBlock [
	"Just evaluate the block since we aren't libgit, but this should not happen"

	| sender exceptions |
	sender := thisContext sender method.
	exceptions := { IceAbstractProject>>#packages }.

	(exceptions includes: sender) 
		ifFalse: [ IceGitCliCallsLibgitFFI signal ].

	aBlock value
]

{ #category : #'API - accessing' }
IceGitCliRepository >> head [
	| headRef lines ref |

	(head notNil and: [ head isCurrentHead ]) ifTrue: [ ^ head ].
	lines := [ self runGitWithArgs: {
		'show'.
		'-s'.
		'--format=tformat:%H%n%D'.
		'HEAD' } ] onErrorDo: [ ^ IceGitUnbornBranch inRepository: self ].
	headRef := lines at: 1.
	ref := ((lines at: 2) splitOn: ', ') first.
	^ head := (ref includesSubstring: '->')
			ifTrue: [ self basicNewBranchNamed: (ref splitOn: ' -> ') second ]
			ifFalse: [ self commitFromGitCommit: headRef ]
]

{ #category : #'private - commits' }
IceGitCliRepository >> iceGitCommitFromLines: lines [
	| author datetime message id parents |
	id := lines at: 1.
	author := lines at: 2.
	datetime := DateAndTime fromUnixTime: (lines at: 3) asInteger.
	parents := (lines at: 4) 
			ifEmpty: [ #() ] 
			ifNotEmpty: [ :line | line splitOn: ' ' ].
	message := String streamContents: [ :str | 
			6 to: lines size do: [ :i | 
				str nextPutAll: (lines at: i); cr ] ].
	^ IceGitCliCommit new
		id: id;
		author: author;
		datetime: datetime;
		ancestorIds: parents;
		comment: message;
		repository: self;
		yourself
]

{ #category : #actions }
IceGitCliRepository >> initBare: isBareRepository [
	| args |
	args := { 'init' } asOrderedCollection.
	isBareRepository ifTrue: [ args add: '--bare' ].
	self runGitWithArgs: args
]

{ #category : #initialization }
IceGitCliRepository >> initialize [
	super initialize.
	remoteMap := Dictionary new.
	revListMap := Dictionary new.
	commitMap := Dictionary new
]

{ #category : #'private - commits' }
IceGitCliRepository >> internalStoreVersion: aMCVersion [
	self writerClass
		forInternalStoreFileOut: aMCVersion 
		on: self
]

{ #category : #testing }
IceGitCliRepository >> isCodeMissing [
	^ self subdirectory isEmptyOrNil 
		ifTrue: [ self isMissing ]
		ifFalse: [ (self repositoryDirectory / self subdirectory) exists not  ]
]

{ #category : #testing }
IceGitCliRepository >> isMissing [
	^ self repositoryDirectory isNil 
		or: [ self repositoryDirectory exists not ]
]

{ #category : #testing }
IceGitCliRepository >> isValid [
	^ self isMissing not
]

{ #category : #'API - branches' }
IceGitCliRepository >> localBranches [
	| branches |
	branches := self runGitWithArgs: {
		'branch'.
		'--format=%(refname:short)' }.
	^ OrderedCollection streamContents: [ :stream | 
		branches do: [ :br | stream nextPut: (self basicNewBranchNamed: br) ] ]
]

{ #category : #accessing }
IceGitCliRepository >> location [
	^ location
]

{ #category : #accessing }
IceGitCliRepository >> location: aLocation [
	location := aLocation 
]

{ #category : #accessing }
IceGitCliRepository >> log [
	^ self logClass for: self
]

{ #category : #accessing }
IceGitCliRepository >> logClass [
	^ (self properties at: #format) == #filetree
		ifTrue: [ IceLibgitFiletreeLog ]
		ifFalse: [ GitCliTonelLog ]
]

{ #category : #'API - commits' }
IceGitCliRepository >> lookupCommit: commitId ifAbsent: aBlock [
	^ [ self commitFromGitCommit: commitId ] onErrorDo: [ aBlock value ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupLocalBranch: branchName [
	^ self lookupLocalBranch: branchName ifAbsent: [ nil ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupLocalBranch: branchName ifAbsent: aBlock [
	| lines |
	lines := self
			runGitWithArgs: {'branch'.
					branchName.
					'--list'.
					'--format=%(objectname)'}.
	^lines isEmpty ifTrue: [ aBlock value ] ifFalse: [ lines first ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupRemoteBranch: branchName [
	^self lookupRemoteBranch: branchName ifAbsent: [nil]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupRemoteBranch: branchName ifAbsent: aBlock [
	| lines |
	lines := self
			runGitWithArgs: {'branch'.
					branchName.
					'--remotes'.
					'--list'.
					'--format=%(objectname)'}.
	^ lines isEmpty ifTrue: [ aBlock value ] ifFalse: [ lines first ]
]

{ #category : #actions }
IceGitCliRepository >> makeSafe [
]

{ #category : #accessing }
IceGitCliRepository >> mcVersionFor: iceVersion [
	[ | commit |
	commit := iceVersion commit cliGitCommit.
	^ (self readerClass on: commit iceVersion: iceVersion) version ]
		on: Error
		do: [ IceVersionDoesNotExist new
				version: iceVersion;
				signal ]
]

{ #category : #ancestry }
IceGitCliRepository >> mergeBaseBetween: id1 and: id2 [
	| lines |
	lines := self runGitWithArgs: {
		'merge-base'.
		id1.
		id2 }.
	^ lines first
]

{ #category : #'API - accessing' }
IceGitCliRepository >> name [
	^ name ifNil: [ name := self obtainRepositoryName ]
]

{ #category : #'API - accessing' }
IceGitCliRepository >> newCommitWalk [
	^ IceGitCliCommitWalk forRepository: self
]

{ #category : #'private - changes' }
IceGitCliRepository >> newIndex [
	^ IceGitCliIndex on: self
]

{ #category : #'API - commits' }
IceGitCliRepository >> newNoCommit [
	^ IceNoCommit repository: self
]

{ #category : #'API - accessing' }
IceGitCliRepository >> obtainRepositoryName [
	^ self location basename
]

{ #category : #'API - remotes' }
IceGitCliRepository >> origin [
	^ self
			remoteNamed: 'origin'
			ifAbsent: [ IceUndefinedRemote new
					name: 'origin';
					yourself ]
]

{ #category : #'API - remotes' }
IceGitCliRepository >> originUrl [
	^ self origin url
]

{ #category : #'private - tags' }
IceGitCliRepository >> peelTag: anIceTag [
	| id lines |
	lines := self runGitWithArgs: {
		'show'.
		'-s'.
		'--format=tformat:%H'.
		anIceTag name }.
	id := lines first.
	^ self lookupCommit: id
]

{ #category : #'API - project' }
IceGitCliRepository >> project [
	^ self workingCopy project
]

{ #category : #accessing }
IceGitCliRepository >> properties [
	^ self workingCopy repositoryProperties
]

{ #category : #'API - branches' }
IceGitCliRepository >> pullBranch: aString from: aRemote [
	self runGitWithArgs: {
		'pull'.
		aRemote name.
		aString }.
	self clearCaches
]

{ #category : #'API - branches' }
IceGitCliRepository >> pushBranch: aString to: aRemoteName [
	self runGitWithArgs: {
		'push' .
		'--set-upstream'.
	    aRemoteName . 
	    aString }
]

{ #category : #accessing }
IceGitCliRepository >> readerClass [
	^ (self properties at: #format) == #filetree
		ifTrue: [ IceGitCliFiletreeReader ]
		ifFalse: [ IceGitCliFileReader ]
]

{ #category : #accessing }
IceGitCliRepository >> remoteAt: aString put: aRemote [
	self addRemote: aRemote name url: aRemote url
]

{ #category : #'API - branches' }
IceGitCliRepository >> remoteBranchNamed: aString ifPresent: presentBlock ifAbsent: absentBlock [
	| found |
	found := self lookupRemoteBranch: aString ifAbsent: [ nil ].
	^ found
		ifNil: absentBlock
		ifNotNil: [ presentBlock value: (self basicNewRemoteBranchNamed: aString) ]
]

{ #category : #'API - remotes' }
IceGitCliRepository >> remoteNamed: aName ifAbsent: aBlockClosure [
	self remotes.	"Compute cache if empty"
	^ remoteMap at: aName ifAbsent: aBlockClosure
]

{ #category : #'API - branches' }
IceGitCliRepository >> remoteTrackedBranches [
	| branches lines |
	lines := self runGitWithArgs: {
		'branch'.
		'--remote'.
		'--format=%(refname)' }.
	branches := lines collect: #trimBoth.
	^ branches collect: [ :each | self basicNewRemoteBranchNamed: each ]
]

{ #category : #'API - remotes' }
IceGitCliRepository >> remotes [
	| lines |
	(remoteMap isEmpty and: [ location isNotNil and: [ location exists ] ])
		ifTrue: [ lines := self runGitWithArgs: {'remote'}.
			lines
				do: [ :each | 
					| l |
					l := self
							runGitWithArgs: {'remote'.
									'get-url'.
									each}.
					remoteMap
						at: each
						put: ((IceGitRemote name: each url: l first)
								localRepository: self;
								yourself) ] ].
	^ remoteMap values
]

{ #category : #'API - accessing' }
IceGitCliRepository >> repositoryDirectory [
	^ self location
]

{ #category : #accessing }
IceGitCliRepository >> repositoryHandle [
	"This should not happen"
	
	IceGitCliCallsLibgitFFI signal.
	
	^ self
]

{ #category : #accessing }
IceGitCliRepository >> resetCurrentBranchTo: aCommitId [
	self runGitWithArgs: {
		'reset'.
		'--hard'.
		aCommitId
	} 
]

{ #category : #'API - commits' }
IceGitCliRepository >> revList [
	| lines |
	lines := self
			runGitWithArgs: {'rev-list'.
					'--all'.
					'--remotes'}.
	^ lines collect: #trimBoth
]

{ #category : #'API - commits' }
IceGitCliRepository >> revListForBranch: aBranch [
	^ self revListForCommit: aBranch commit id
]

{ #category : #'API - commits' }
IceGitCliRepository >> revListForCommit: aCommit [
	^ revListMap
		at: aCommit
		ifAbsentPut: [ | lines |
			lines := self runGitWithArgs: {
				'rev-list'.
				aCommit }.
			lines collect: #trimBoth ]
]

{ #category : #'API - commits' }
IceGitCliRepository >> revListForCommit: aCommit andPath: aPath [
	| lines |
	lines := self runGitWithArgs: {
		'rev-list'.
		aCommit.
		'--'.
		aPath }.
	^ lines collect: #trimBoth
]

{ #category : #'API - accessing' }
IceGitCliRepository >> revparse: aName [
	| id |
	id := (self runGitWithArgs: { 'rev-parse'. aName }) first.
	^ self commitFromGitCommit: id
]

{ #category : #private }
IceGitCliRepository >> runGitWithArgs: args [
	"Run CLI git with the passed arguments and return the lines from standard output.
	Wait for the git command to complete. Signal an error when not successful."

	| operation executor |
	operation := thisContext sender method selector.
	executor := IceGitCliPlatform current executor.
	executor workingDirectory: self validLocation.
	^ executor runGitWithArgs: args for: operation
]

{ #category : #accessing }
IceGitCliRepository >> setBranch: branchName to: aCommitId [
	self runGitWithArgs: {
		'branch'.
		'-f'.
		branchName.
		aCommitId
	} 
]

{ #category : #'API - accessing' }
IceGitCliRepository >> setHead: aGtIceGitLocalBranch [
	self runGitWithArgs: {
		'checkout'.
		'-f'.
		aGtIceGitLocalBranch gitRef }.
	head := nil
]

{ #category : #private }
IceGitCliRepository >> statusEnumFrom: statusChar [
	| flagMap |
	flagMap := { 
		$M -> 2.
		$T -> 16.
		$A -> 1.
		$D -> 4.
		$R -> 8.
		$? -> 128.
		$! -> 16384 } asDictionary.
	^ LGitStatusEnum basicNew value: (flagMap at: statusChar)
]

{ #category : #'API - accessing' }
IceGitCliRepository >> subdirectory [
	^ self project sourceDirectory
]

{ #category : #'API - accessing' }
IceGitCliRepository >> subdirectoryPath [
	
	"API compatible both with Pharo6 and Pharo7.
	This could be replaced by the Pharo7 API
	
	RelativePath with: self subdirectory
	"
	^ RelativePath withAll: (RelativePath canonicalizeElements: ($/ split: self subdirectory))
]

{ #category : #accessing }
IceGitCliRepository >> subdirectoryReference [
	^ self location resolve: self subdirectoryPath
]

{ #category : #'API - tags' }
IceGitCliRepository >> tags [
	| lines |
	lines := self runGitWithArgs: { 'tag' }.
	^ lines collect: [ :each | IceTag named: each inRepository: self ]
]

{ #category : #'API - tags' }
IceGitCliRepository >> tagsFor: anId [
	| lines |
	lines := self runGitWithArgs: {
		'tag'.
		'--points-at'.
		anId }.
	^ lines collect: [ :each | IceTag named: each inRepository: self ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> upstreamForBranch: localBranchName [
	^ self runGitWithArgs: {
		'branch'.
		'--list'.
		'--format=%(upstream)'.
		localBranchName }.
]

{ #category : #accessing }
IceGitCliRepository >> validLocation [
	(location isNil or: [ location exists not ])
		ifTrue: [ GtGitRepositoryLocationDoesntExist new
				fileReference: location;
				repository: self;
				signal ].
	^ location
]

{ #category : #'API - commit' }
IceGitCliRepository >> writeCommit: indexTreeId message: message parents: parentCommits updateReference: ref author: author committer: committer [
	| lines commitId parentArgs args |
	self clearCaches. 
	args := OrderedCollection with: 'commit-tree'.
	IceGitCliPlatform current signCommits 
		ifTrue: [ args add: '-S' ].
	parentArgs := (parentCommits collect: [ :each | { '-p'. each id } ]) flatten.
	args 
		add: indexTreeId; 
		addAll: parentArgs; 
		addAll:  { '-m'. message }.
	lines := self runGitWithArgs: args.
	commitId := lines first trimBoth.
	self runGitWithArgs: {
		'update-ref'.
		'refs/heads/', ref.
		commitId }.
	self runGitWithArgs: {
		'update-ref'.
		'HEAD'.
		commitId }.
	^ commitId
]

{ #category : #'API - commit' }
IceGitCliRepository >> writeTreeAndReturnOid [
	| lines |
	lines := self runGitWithArgs: { 'write-tree' }.
	^ lines first trimBoth
]

{ #category : #'private - commits' }
IceGitCliRepository >> writerClass [
	^ self project writerClass
]
