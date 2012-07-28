functor
export
    isNearBy: IsNearBy

define
    fun {IsNearBy Loc1 Loc2}
        case Loc1#Loc2
        of staying(X1#Y1)#staying(X2#Y2) then
            DX = X1-X2
            DY = Y1-Y2
        in
            DX*DX + DY*DY < 0.2*0.2
        else
            false
        end
    end
end

