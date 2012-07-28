functor
import
    XPerson(person:Person) at 'Person.ozf'

export
    alice: Alice
    bob: Bob

define
    Alice = {New Person init(alice  fun {$ T}
        Hours = T mod (24*60)
    in
        if Hours < 8*60 then
            staying(12.0#20.0)
        elseif Hours < 8*60+30 then
            moving(12.0#20.0  15.0#23.0)
        elseif Hours < 17*60 then
            staying(15.0#23.0)
        elseif Hours < 17*60+30 then
            moving(15.0#23.0  12.0#20.0)
        else
            staying(12.0#20.0)
        end
    end)}

    Bob = {New Person init(bob  fun {$ T}
        Hours = T mod (24*60)
    in
        if Hours < 8*60+30 then
            staying(15.0#20.0)
        elseif Hours < 8*60+45 then
            moving(15.0#20.0  15.0#23.0)
        elseif Hours < 17*60+5 then
            staying(15.0#23.0)
        elseif Hours < 17*60+10 then
            moving(15.0#23.0  15.1#23.0)
        elseif Hours < 18*60+10 then
            staying(15.1#23.0)
        elseif Hours < 18*60+30 then
            moving(15.1#23.0  15.0#20.0)
        else
            staying(15.0#20.0)
        end
    end)}
end

