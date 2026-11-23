Class {
	#name : #PureGitCodeExamples,
	#superclass : #Object,
	#instVars : [
		'codeRepositoriesDirectory'
	],
	#category : #'Iceberg-Git-CLI-Pure-Code'
}

{ #category : #examples }
PureGitCodeExamples >> cleanUpCodeRepositories [
	"Delete the code repositories this run of an example laid out"

	codeRepositoriesDirectory ifNil: [ ^ self ].
	codeRepositoriesDirectory ensureDeleteAll.
	codeRepositoriesDirectory := nil
]

{ #category : #examples }
PureGitCodeExamples >> codeRepositoriesDirectory [
	"Answer the directory under which this run of an example lays out its code repositories.
	The name is unique: examples can run in parallel, for example in different RemoteRunner workers, which share the temporary directory"

	^ codeRepositoriesDirectory ifNil: [
		codeRepositoriesDirectory := FileLocator temp / (self class name , '-' , UUID new asString) ]
]

{ #category : #examples }
PureGitCodeExamples >> codeRepositoryNamed: aName project: aProjectString sourceDirectory: aDirectoryName [
	"Answer a fresh directory laid out like a code repository: a .project file with aProjectString,
	and the .properties file of its source directory, as Iceberg writes them"

	| location |
	location := self codeRepositoriesDirectory / aName.
	location exists ifTrue: [ location ensureDeleteAll ].
	location ensureCreateDirectory.
	(location / '.project') writeStreamDo: [ :out | out nextPutAll: aProjectString ].
	(location / aDirectoryName) ensureCreateDirectory.
	(location / aDirectoryName / '.properties') writeStreamDo: [ :out |
		out nextPutAll: '{ #format : #tonel }' ].
	^ location
]

{ #category : #examples }
PureGitCodeExamples >> exampleCodeRepositoryWithSourceDirectory [
	"Iceberg writes the source directory in .project with a String key"
	<gtExample>
	<after: #cleanUpCodeRepositories>
	<return: #PureGitCodeRepository>
	| location repository |
	location := self
		codeRepositoryNamed: 'source-directory'
		project: '{ ''srcDirectory'' : ''repository'' }'
		sourceDirectory: 'repository'.
	repository := PureGitCodeRepository on: location.
	self assert: repository srcDirectory basename equals: 'repository'.
	self assert: repository srcDirectory exists.
	^ repository
]

{ #category : #examples }
PureGitCodeExamples >> exampleCodeRepositoryWithSymbolSourceDirectoryKey [
	"Some .project files have the source directory with a Symbol key"
	<gtExample>
	<after: #cleanUpCodeRepositories>
	<return: #PureGitCodeRepository>
	| location repository |
	location := self
		codeRepositoryNamed: 'symbol-source-directory-key'
		project: '{ #srcDirectory : ''source'' }'
		sourceDirectory: 'source'.
	repository := PureGitCodeRepository on: location.
	self assert: repository srcDirectory basename equals: 'source'.
	self assert: repository srcDirectory exists.
	^ repository
]
