functor
import
    Handpassed at 'Handpassed.ozf'
    Timer at 'Timer.ozf'
    Person at 'Person.ozf'
    SamplePeople at 'SamplePeople.ozf'
    System(showInfo:Show)
    Application

define
    % Install the "debugger" and Handpassed to everyone.
    {Timer.registerTimeChangedHandler proc {$ T}
        Hours = T div 60
        Minutes = T mod 60
    in
        {Show '===== At time '#Hours#':'#Minutes#':'}
        {ForAll {Person.getAllPeople} Handpassed.showPackageStatus}
    end}
    {ForAll {Person.getAllPeople} Handpassed.install}

    % Create connection and load a package transfer.
    {SamplePeople.alice connect(person:SamplePeople.bob)}
    {Handpassed.addPackageToTransfer SamplePeople.alice  cable  staying(15.0#23.0)  9*60  12*60  bob}
    {Handpassed.addPackageToReceive SamplePeople.bob  cable}
    {Handpassed.addPackageToTransfer SamplePeople.alice  nonsense  staying(15.0#23.0)  9*60  12*60  nobody}
    {Handpassed.addPackage SamplePeople.alice cable}
    {Handpassed.addPackage SamplePeople.alice nonsense}


    for I in 0..14*12 do
        {Timer.increaseTime 5}
    end

    {Application.exit 0}
end

