Class {
	#name : #BaselineOfIcebergGitCli,
	#superclass : #BaselineOf,
	#category : #BaselineOfIcebergGitCli
}

{ #category : #baseline }
BaselineOfIcebergGitCli >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'Iceberg-Git-Cli'.
			spec package: 'Iceberg-Git-Cli'.
			spec package: 'Iceberg-Git-Cli'
		]
]
