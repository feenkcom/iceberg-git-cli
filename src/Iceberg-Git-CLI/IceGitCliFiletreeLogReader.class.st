Class {
	#name : #IceGitCliFiletreeLogReader,
	#superclass : #IceLibgitFiletreeLogReader,
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #'as yet unclassified' }
IceGitCliFiletreeLogReader >> fileUtils [
	^IceGitCliFiletreeFileUtils
]

{ #category : #'as yet unclassified' }
IceGitCliFiletreeLogReader >> loadDefinitions [
	| entry segments className classIsMeta entryPath packageIndex |
	definitions := OrderedCollection new.

	segments := (self fileName substrings: '/') allButLast asOrderedCollection.
	classIsMeta := segments removeLast = 'class'.
	className := segments last copyUpToLast: $..	"entryPath is the relative path from the package to the method being loaded"
	packageIndex := segments indexOf: packageDirectory filename.
	entryPath := packageIndex > 0
			ifTrue: [ | p |
				p := $/ join: (segments copyFrom: 1 to: packageIndex).
				self fileName allButFirst: p size + 1 ]
			ifFalse: [ self fileName allButFirst: packageDirectory filename size ].
	entry := packageDirectory resolveString: entryPath.
	entry
		readStreamDo: [ :fileStream | 
			| category source timestamp selector |
			category := fileStream nextLine.
			source := fileStream upToEnd.
			selector := self methodSelectorFor: source.
			timestamp := stream author , ' '
					, stream timeStamp asStringYMDHM.
			definitions
				add: (MCMethodDefinition
						className: className
						classIsMeta: classIsMeta
						selector: selector
						category: category
						timeStamp: timestamp
						source: source) ]
]
