Class {
	#name : #GitCliFiletreeLog,
	#superclass : #IceLibgitFiletreeLog,
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #private }
GitCliFiletreeLog >> collectCommitsFor: aMethod path: aPath [
	| commits |
	commits := repository revListForCommit: repository headCommit id andPath: aPath.
	^ commits collect: [ :each | repository commitFromGitCommit: each ]
]

{ #category : #private }
GitCliFiletreeLog >> collectVersionsFrom: aCollection method: aMethod path: aPath [
	| lastDefinition basepath history |
		
	basepath := self basepathOf: aPath.
	lastDefinition := MCMethodDefinition new.
	history := OrderedCollection new.
	aCollection reverseDo: [ :eachCommit | | definition |
		definition := self definitionFor: aMethod path: basepath commit: eachCommit.
		lastDefinition = definition  ifFalse: [ 
			history add: (IceLogVersion 
				commit: eachCommit
				definition: definition asRingDefinition).
			lastDefinition := definition ] ].

	^ history reversed
]

{ #category : #'as yet unclassified' }
GitCliFiletreeLog >> definitionFor: aMethod path: aPath commit: aCommit [
	^ ((IceGitCliFiletreeLogReader fileName: aPath on: aCommit)
		package: aMethod package mcPackage;
		packageDirectory: (self repository directoryPathStringForPackage: aMethod package);
		definitions)
		detect: [ :each | 
			each isMethodDefinition
				and: [ each selector = aMethod selector
						and: [ each method isClassSide = aMethod isClassSide ] ] ]
		ifNone: [ 
		MCMethodDefinition
				className: aMethod origin name
				selector: aMethod selector
				category: #''
				timeStamp: nil
				source: '' ]
]
