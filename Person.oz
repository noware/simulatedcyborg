functor
import
    Timer at 'Timer.ozf'
    Location at 'Location.ozf'

export
    person: Person
    getAllPeople: GetAllPeople
    isPersonNearBy: IsPersonNearBy

define
    AllPeople = {NewDictionary}

    % Get the objects to all people. Should only be used in time-changed
    % handlers to propagate the time.
    fun {GetAllPeople}
        {Dictionary.items AllPeople}
    end

    % Check whether a person is near a given location.
    fun {IsPersonNearBy PsId Loc}
        case {Dictionary.condGet AllPeople PsId unit}
        of unit then
            false
        [] Person then
            {Location.isNearBy {Person getCurrentLocation(location:$)} Loc}
        end
    end

    % A person
    class Person from BaseObject
	feat
	    states	% <- change to a database?
	    messageHandlers
            timeChangedHandlers
	    incomingStream
	    incomingPort
	    outgoingPorts
            name
        attr
            location
            movementFunction

	meth ServerLoop
            for (Id#PsId#M)#R in self.incomingStream do
                case {Dictionary.condGet self.messageHandlers Id unit}
                of unit then
                    % assign the return value R with something?
                    skip
                [] Handler then
                    R = {Handler self M PsId {Timer.getTime}}
                end
            end
	end

        % Initialize the person with their movement function.
        % {MovementFunction T ?Loc}
        meth init(Name MovementFunction)
            self.name = Name
            self.states = {NewDictionary}
            self.messageHandlers = {NewDictionary}
            self.timeChangedHandlers = {NewDictionary}
            self.outgoingPorts = {NewDictionary}
            movementFunction := MovementFunction
            location := {@movementFunction {Timer.getTime}}
            self.incomingPort = {NewPort self.incomingStream}
            thread {self ServerLoop} end
            {Dictionary.put AllPeople Name self}
            {Timer.registerTimeChangedHandler proc {$ T}
                location := {@movementFunction T}
                for Handler in {Dictionary.items self.timeChangedHandlers} do
                    {Handler self T}
                end
            end}
        end

        % Get the current location.
        meth getCurrentLocation(location:?Loc)
            Loc = @location
        end

        % Get the future location at T.
        meth getFutureLocation(time:T location:?Loc)
            Loc = {@movementFunction T}
        end

        % Change the movement function of this person.
        meth setMovementFunction(NewMovementFunction)
            movementFunction := NewMovementFunction
        end

        % Get an application-specific state.
	meth getState(appId:Id state:?S default:Default)
	    S = {Dictionary.condGet self.states Id Default}
	end

        % Exchange the application-specific state.
	meth exchangeState(appId:Id oldState:S0 newState:S1 default:Default)
            {Dictionary.condExchange self.states Id Default S0 S1}
	end

        % Set the message handler for an application.
        % {P Self M SenderPsId T ?Reply}
	meth setMessageHandler(appId:Id handler:P)
	    {Dictionary.put self.messageHandlers Id P}
	end

        % Set the time-changed handler for an application.
        % {P Self T}
        meth setTimeChangedHandler(appId:Id handler:P)
            {Dictionary.put self.timeChangedHandlers Id P}
        end

        % Send a message to another person.
	meth sendMessage(appId:Id person:PsId message:M reply:?R<=_)
            % Handle sending message to unconnected people?
            ThePort = self.outgoingPorts.PsId
        in
            {Port.sendRecv ThePort Id#self.name#M R}
	end

        % Get all people this person knows.
        meth getConnections(people:?PsIds)
            PsIds = {Dictionary.keys self.outgoingPorts}
        end

        % Connect with another person
        meth connect(person:OtherPerson)
            % What if two people share the same handle?
            {Dictionary.put
                self.outgoingPorts
                OtherPerson.name
                OtherPerson.incomingPort}
        end
    end
end


