Class {
	#name : #IceGitCliExecutor,
	#superclass : #Object,
	#instVars : [
		'workingDirectory'
	],
	#category : #'Iceberg-Git-CLI-Support'
}

{ #category : #private }
IceGitCliExecutor >> git [
	| processBuilder |
	processBuilder := GtExternalProcessBuilder new.
	processBuilder command: IceGitCliPlatform current gitExecutable.
	self workingDirectory
		ifNotNil: [ processBuilder workingDirectory: self workingDirectory ].
	^ processBuilder
]

{ #category : #accessing }
IceGitCliExecutor >> gitHelpFor: command [
	| output lines backspace |
	output := self runGitWithArgs: { command . '--help' }.
	backspace := Character backspace.
	lines := output collect: [ :line | 
		String streamContents: [ :out | 
			line do: [ :each |
				each = backspace
					ifTrue: [ out skip: -1 ]
					ifFalse: [ out nextPut: each ] ] ] ].
	^ String cr join: lines
]

{ #category : #accessing }
IceGitCliExecutor >> gitVersion [
	<gtExample>
	<noTest>

	^ (self runGitWithArgs: #( '--version' )) first
]

{ #category : #logging }
IceGitCliExecutor >> logEnded: operation args: args output: output [
	self loggingEnabled
		ifTrue: [ (IceGitCliPlatform current signalClass args: args output: output)
				operation: operation;
				markAsEndSignal;
				emit ]
]

{ #category : #logging }
IceGitCliExecutor >> logStarted: operation args: args [
	self loggingEnabled
		ifTrue: [ (IceGitCliPlatform current signalClass args: args)
				operation: operation;
				markAsStartSignal;
				emit ]
]

{ #category : #logging }
IceGitCliExecutor >> loggingEnabled [
	^ IceGitCliPlatform current signalClass notNil
]

{ #category : #public }
IceGitCliExecutor >> runGitRawWithArgs: args for: operation [
	"Run CLI git with the passed arguments and return the raw bytes from standard output.
	Wait for the git command to complete. Signal an error when not successful."

	| processBuilder result output |
	self logStarted: operation args: args.
	processBuilder := self git args: args.
	output := self waitForProcessAsync: processBuilder.
	output status isSuccess 
		ifFalse: [
			result := output stderr lines.
			self logEnded: operation args: args output: result.
			^ GtGitCliCommandError new
				args: args;
				stderr: result;
				exitCode: output status code;
				signal ].
	result := output stdoutBytes.
	self logEnded: operation args: args output: { result size asString , ' bytes' }.
	^ result
]

{ #category : #public }
IceGitCliExecutor >> runGitWithArgs: args [
	"Run CLI git with the passed arguments and return the lines from standard output.
	Wait for the git command to complete. Signal an error when not successful."

	| operation |
	operation := thisContext sender method selector.
	^ self runGitWithArgs: args for: operation
]

{ #category : #public }
IceGitCliExecutor >> runGitWithArgs: args for: operation [
	"Run CLI git with the passed arguments and return the lines from standard output.
	Wait for the git command to complete. Signal an error when not successful."

	| processBuilder lines output |
	self logStarted: operation args: args.
	processBuilder := self git args: args.
	output := self waitForProcessAsync: processBuilder.
	output status isSuccess 
		ifFalse: [
			lines := output stderr lines.
			self logEnded: operation args: args output: lines.
			^ GtGitCliCommandError new
				args: args;
				stderr: lines;
				exitCode: output status code;
				signal ].
	lines := output stdout lines.
	self logEnded: operation args: args output: lines.
	^ lines
]

{ #category : #public }
IceGitCliExecutor >> runGitWithArgsAsync: args for: operation [
	"Run CLI git with the passed arguments and return the lines from standard output as an asynchroneous stream.
	Do not wait for the git command to complete. (Signal an error when not successful.)"

	| processBuilder child "status" |
	self logStarted: operation args: args.
	processBuilder := self git args: args.
	child := self spawnProcessAsync: processBuilder.
	"status := child wait.
	status isSuccess 
		ifFalse: [ | lines |
			lines := child stderr lines.
			self logEnded: operation args: args output: lines.
			^ GtGitCliCommandError new
				args: args;
				stderr: lines;
				exitCode: status code;
				signal ]."
	self logEnded: operation args: args output: #('Asynchroneous output').
	^ child stdoutStream lines
]

{ #category : #private }
IceGitCliExecutor >> spawnProcessAsync: processBuilder [
	"Run the native process described in processBuilder but do not wait for it to complete or produce output.
	The result, an instance of GtNativeExternalProcessChild, can be queried for its status, stdout and stderr.
	This will not block the current process nor the VM"

	| nativeProcess |
	processBuilder 
		pipeStdout; 
		pipeStderr.
	nativeProcess := processBuilder spawn.
	^ nativeProcess
]

{ #category : #private }
IceGitCliExecutor >> waitForProcess: processBuilder [
	"Run the native process described in processBuilder and wait for it to complete and produce output.
	The output, an instance of GtNativeExternalProcessOutput, can be queried for its status and stdout.
	This wait will block the VM."
	
	^ processBuilder output
]

{ #category : #private }
IceGitCliExecutor >> waitForProcessAsync: processBuilder [
	"Run the native process described in processBuilder and wait for it to complete and produce output.
	The output, an instance of GtNativeExternalProcessOutput, can be queried for its status, stdout and stderr.
	This wait will block the current process but not the VM"

	| nativeProcess |
	processBuilder 
		pipeStdout; 
		pipeStderr.
	nativeProcess := processBuilder spawn.
	^ nativeProcess waitAsyncWithOutput
]

{ #category : #accessing }
IceGitCliExecutor >> workingDirectory [
	^ workingDirectory
]

{ #category : #accessing }
IceGitCliExecutor >> workingDirectory: aFileReference [
	workingDirectory := aFileReference
]
