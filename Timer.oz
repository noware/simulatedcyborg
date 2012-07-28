functor
export
    increaseTime: IncreaseTime
    getTime: GetTime
    registerTimeChangedHandler: RegisterTimeChangedHandler

define
    local
        SharedTimer = {NewCell 0}
        TimeChangedHandlers = {NewCell nil}
    in
        proc {IncreaseTime Dt}
            OldTime
        in
            % assert Dt >= 0 ?
            {Exchange SharedTimer OldTime thread OldTime + Dt end}
            {ForAll @TimeChangedHandlers proc {$ P} {P @SharedTimer} end}
        end

        fun {GetTime}
            @SharedTimer
        end

        proc {RegisterTimeChangedHandler Handler}
            OldHandlers
        in
            % assert Handler is a procedure which takes an integer?
            {Exchange TimeChangedHandlers OldHandlers thread Handler|OldHandlers end}
        end
    end
end

