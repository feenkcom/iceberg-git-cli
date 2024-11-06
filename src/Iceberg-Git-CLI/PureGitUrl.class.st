"
I interpret a string as a git URL.

Supported examples:

git@github.com:svenvc/svc-demo.git
https://github.com/svenvc/svc-demo.git

git@gitlab.com:gitlab-org/gitlab.git
https://gitlab.com/gitlab-org/gitlab.git

git@bitbucket.org:teamsinspace/documentation-tests.git
https://bitbucket.org/teamsinspace/documentation-tests.git

optional username@host:port

ssh://user@host:8899/path/to/git/repo

/path/to/repo
file:///path/to/repo


"
Class {
	#name : #PureGitUrl,
	#superclass : #Object,
	#instVars : [
		'url'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #examples }
PureGitUrl class >> examples [
	<gtExample>
	^ #(
		'git@github.com:svenvc/svc-demo.git'
		'https://github.com/svenvc/svc-demo.git'
		'git@gitlab.com:gitlab-org/gitlab.git'
		'https://gitlab.com/gitlab-org/gitlab.git'
		'git@bitbucket.org:teamsinspace/documentation-tests.git'
		'https://bitbucket.org/teamsinspace/documentation-tests.git'
		'ssh://user@host:8899/path/to/git/repo'
		'git@gitlab.com:jantopgroup/middlegroup/innergroup/project.git'
		'/path/to/repo'
		'file:///path/to/repo'
	) 
		collect: [ :each | self with: each ]
]

{ #category : #'instance creation' }
PureGitUrl class >> with: aUrlString [
	^ self new
		url: aUrlString;
		yourself
]

{ #category : #operations }
PureGitUrl >> cloneIn: aDirectory [
	| location repository |
	location := aDirectory asFileReference / self repositoryName.
	(location exists and: [ location hasChildren ])
		ifTrue: [ ^ DirectoryIsNotEmpty signalWith: location ].
	repository := PureGitRepository on: location.
	repository operations clone: self url.
	^ repository
]

{ #category : #operations }
PureGitUrl >> cloneWithOwnerPrefixIn: aDirectory [
	self assert: self isFileUrl not.
	^ self cloneIn: aDirectory asFileReference / self ownerName
]

{ #category : #accessing }
PureGitUrl >> fileReference [
	^ self fileUrl asFileReference
]

{ #category : #accessing }
PureGitUrl >> fileUrl [
	self assert: self isFileUrl.
	^ ZnUrl fromString: url defaultScheme: #file
]

{ #category : #accessing }
PureGitUrl >> gitHubWebUrl [
	self isNetworkUrl ifFalse: [ ^ nil ].
	self hostname = 'github.com' ifFalse: [ ^ nil ].
	^ 'https://github.com' asUrl
		/ self ownerName
		/ self repositoryName
]

{ #category : #accessing }
PureGitUrl >> groupName [
	^ self ownerName
]

{ #category : #accessing }
PureGitUrl >> hostname [
	| znUrl |
	self assert: self isNetworkUrl.
	self isScpUrl
		ifTrue: [ ^ ($: split: self url) first allButFirst: 4 ].
	znUrl := ZnUrl fromString: self url.
	^ znUrl host
]

{ #category : #testing }
PureGitUrl >> isFileUrl [
	^ url first = $/ or: [ url beginsWith: 'file:///' ]
]

{ #category : #testing }
PureGitUrl >> isHttpsUrl [
	^ url beginsWith: 'https://'
]

{ #category : #testing }
PureGitUrl >> isNetworkUrl [
	^ self isSshUrl | self isScpUrl | self isHttpsUrl
]

{ #category : #testing }
PureGitUrl >> isScpUrl [
	^ url beginsWith: 'git@'
]

{ #category : #testing }
PureGitUrl >> isSshUrl [
	^ url beginsWith: 'ssh://'
]

{ #category : #accessing }
PureGitUrl >> ownerName [
	| znUrl |
	self isFileUrl ifTrue: [ ^ nil ].
	self isScpUrl
		ifTrue: [ | path segments |
			path := ($: split: self url) second.
			segments := $/ split: path.
			^ $/ join: segments allButLast ].
	znUrl := ZnUrl fromString: self url.
	^ $/ join: znUrl pathSegments allButLast
]

{ #category : #printing }
PureGitUrl >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: self url; nextPut: $)
]

{ #category : #accessing }
PureGitUrl >> projectName [
	^ self repositoryName
]

{ #category : #accessing }
PureGitUrl >> repositoryName [
	| znUrl |
	self isFileUrl
		ifTrue: [
			znUrl := self fileUrl.
			^ self withoutOptionalExtension: znUrl lastPathSegment ].
	self isScpUrl
		ifTrue: [ | path segments |
			path := ($: split: self url) second.
			segments := $/ split: path.
			^ self withoutOptionalExtension: segments last ].
	znUrl := ZnUrl fromString: self url.
	^ self withoutOptionalExtension: znUrl lastPathSegment
]

{ #category : #accessing }
PureGitUrl >> scheme [
	#(file isFileUrl https isHttpsUrl scp isScpUrl ssh isSshUrl) 
		pairsDo: [ :scheme :test | (self perform: test) ifTrue: [ ^ scheme ] ].
	^ nil
]

{ #category : #accessing }
PureGitUrl >> url [
	^ url
]

{ #category : #accessing }
PureGitUrl >> url: aString [
	url := aString
]

{ #category : #private }
PureGitUrl >> withoutOptionalExtension: aString [
	^ (aString endsWith: '.git')
		ifTrue: [ aString allButLast: 4 ]
		ifFalse: [ aString ]
]
