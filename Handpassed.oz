functor
import
    XPerson(isPersonNearBy:IsPersonNearBy) at 'Person.ozf'
    XLocation(isNearBy:IsNearBy) at 'Location.ozf'
    System(show:Show)

export
    addPackageToTransfer: AddPackageToTransfer
    addPackageToReceive: AddPackageToReceive
    addPackage: AddPackage
    showPackageStatus: ShowPackageStatus
    install: Install

define
    AppId = noware_handpassed
    DefaultState = AppId(
        packages: nil
        packageIdsToTransfer: {NewDictionary}
    )

    fun {MessageHandler Person PackageId PsId T}
        PackageStatus
        State
    in
        {Person exchangeState(
            appId: AppId
            oldState: State
            newState: thread
                OldHoldingPackages
                NewHoldingPackages
            in
                OldHoldingPackages = State.packages
                if {Dictionary.member State.packageIdsToTransfer PackageId} then
                    NewHoldingPackages = PackageId|OldHoldingPackages
                    PackageStatus = received
                else
                    NewHoldingPackages = OldHoldingPackages
                    PackageStatus = ignored
                end
                {AdjoinAt State packages NewHoldingPackages}
            end
            default: DefaultState
        )}
        PackageStatus
    end

    proc {TimeChangedHandler H T}
        State
        CurrentLocation = {H getCurrentLocation(location:$)}
    in
        {H exchangeState(
            appId: AppId
            oldState: State
            newState: thread
                PackagesToRemove = for  collect:Yield continue:Continue   PackageId in State.packages do
                    PackageInfo = {Dictionary.condGet State.packageIdsToTransfer PackageId unit}
                in
                    if PackageInfo == unit then
                        {Continue}
                    elseif {IsNearBy PackageInfo.location CurrentLocation}
                            andthen PackageInfo.startTime =< T
                            andthen PackageInfo.endTime > T
                            andthen {IsPersonNearBy PackageInfo.person CurrentLocation} then
                        case {H sendMessage(
                            appId: AppId
                            person: PackageInfo.person
                            message: PackageId
                            reply: $)}
                        of received then
                            {Yield PackageId}
                        else
                            skip
                        end
                    end
                end
            in
                if PackagesToRemove == nil then
                    State
                else
                    NewPackages = {List.subtract State.packages PackagesToRemove}
                    NewPackageInfos = {Dictionary.clone State.packageIdsToTransfer}
                in
                    for PackageId in PackagesToRemove do
                        {Dictionary.remove NewPackageInfos PackageId}
                    end
                    {Adjoin State r(packages:NewPackages packageIdsToTransfer:NewPackageInfos)}
                end
            end
            default: DefaultState
        )}
    end

    proc {Install Person}
        {Person setMessageHandler(appId:AppId handler:MessageHandler)}
        {Person setTimeChangedHandler(appId:AppId handler:TimeChangedHandler)}
    end

    proc {AddPackageToTransfer Person PackageId Loc StartTime EndTime PsId}
        State
    in
        {Person exchangeState(
            appId: AppId
            oldState: State
            newState: thread
                NewPackageInfos = {Dictionary.clone State.packageIdsToTransfer}
            in
                {Dictionary.put NewPackageInfos PackageId r(
                    location: Loc
                    startTime: StartTime
                    endTime: EndTime
                    person: PsId)}
                {AdjoinAt State packageIdsToTransfer NewPackageInfos}
            end
            default: DefaultState
        )}
    end

    proc {AddPackageToReceive Person PackageId}
        State
    in
        {Person exchangeState(
            appId: AppId
            oldState: State
            newState: thread
                NewPackageInfos = {Dictionary.clone State.packageIdsToTransfer}
            in
                {Dictionary.put NewPackageInfos PackageId unit}
                {AdjoinAt State packageIdsToTransfer NewPackageInfos}
            end
            default: DefaultState
        )}
    end


    proc {AddPackage Person PackageId}
        State
    in
        {Person exchangeState(
            appId: AppId
            oldState: State
            newState: thread
                {AdjoinAt State packages PackageId|State.packages}
            end
            default: DefaultState
        )}
    end

    proc {ShowPackageStatus Person}
        State = {Person getState(appId:AppId state:$ default:DefaultState)}
    in
        {Show '--- '#Person.name#' (at '#{Person getCurrentLocation(location:$)}#')'}
        {Show '... Packages in hand: '#State.packages}
        {Show '... Transfer tasks left: '}
        for PackageId#PackageInfo in {Dictionary.entries State.packageIdsToTransfer} do
            {Show '      '#PackageId#': '#PackageInfo}
        end
    end
end

