"
I represent one entry in a git tree.

I hold some minimal meta data: a name, a mode, a type and the hash (id) of the object that I refer to.
"
Class {
	#name : #PureGitTreeEntry,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'name',
		'type',
		'mode',
		'id'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #enumerating }
PureGitTreeEntry >> entriesDoRecursively: block [
]

{ #category : #enumerating }
PureGitTreeEntry >> entriesDoRecursively: block parents: parents [
	self isTree
		ifTrue: [ | next |
			next := parents copyWith: self.
			self subEntries do: [ :entry |
				entry entriesDoRecursively: block parents: next ] ]
		ifFalse: [
			block cull: self cull: parents ]
]

{ #category : #accessing }
PureGitTreeEntry >> id [
	^ id
]

{ #category : #accessing }
PureGitTreeEntry >> id: anObject [
	id := anObject
]

{ #category : #testing }
PureGitTreeEntry >> isTree [
	^ self type = #tree
]

{ #category : #accessing }
PureGitTreeEntry >> mode [
	^ mode
]

{ #category : #accessing }
PureGitTreeEntry >> mode: anObject [
	mode := anObject
]

{ #category : #accessing }
PureGitTreeEntry >> modeDescription [
	| map |
	map := {
		0 -> #new.
		16384 -> #tree.
		33188 -> #blob.
		33261 -> #executable.
		40960 -> #link.
		57344 -> #commit } asDictionary.
	^ map at: self mode ifAbsent: [ #unknown ]
]

{ #category : #accessing }
PureGitTreeEntry >> name [
	^ name
]

{ #category : #accessing }
PureGitTreeEntry >> name: anObject [
	name := anObject
]

{ #category : #printing }
PureGitTreeEntry >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	name ifNotNil: [ stream nextPutAll: name ].
	stream nextPut: $)
]

{ #category : #accessing }
PureGitTreeEntry >> resolve [
	type = #blob ifTrue: [ ^ repository resolveBlob: id ].
	type = #tree ifTrue: [ ^ repository resolveTree: id ].
	self
		assert: (#(blob tree) includes: type)
		description: 'Unknow git tree entry type'
]

{ #category : #accessing }
PureGitTreeEntry >> shortId [
	^ id first: 7
]

{ #category : #accessing }
PureGitTreeEntry >> subEntries [
	^ self isTree
		ifTrue: [ self resolve entries ] 
		ifFalse: [ #() ]
]

{ #category : #accessing }
PureGitTreeEntry >> type [
	^ type
]

{ #category : #accessing }
PureGitTreeEntry >> type: anObject [
	type := anObject
]
