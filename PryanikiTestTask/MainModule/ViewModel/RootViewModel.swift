//
//  RootViewModel.swift
//  PryanikiTestTask
//
//  Created by Maxim Alekseev on 03.02.2021.
//

import RxSwift
import RxCocoa

struct RootViewModel {
    
    enum VCStates {
        case Sections
        case Variants([Variant])
    }
    
    private let resource = Resource<ResourceResponse>(urlString: "https://pryaniky.com/static/json/sample.json")
    private let disposeBag = DisposeBag()
    
    var vcStates: BehaviorRelay<VCStates> = BehaviorRelay(value: .Sections)
    
    var sections: BehaviorRelay<[Section]> = BehaviorRelay(value: [])
    
    
    init() {
        
        NetworkDataFetcher.shared.fetchData(resource: resource)
            .compactMap { resourceResponse -> [Section]? in
                return resourceResponse?.view
                    .compactMap({ viewName in
                        
                        guard let resourceData = resourceResponse?.data
                                .first(where: { $0.name == viewName })
                        else { return nil }
                        
                        return Section(resourceData: resourceData)
                    })
            }.bind(to: self.sections).disposed(by: disposeBag)
    }
    
}

struct Section {
    
    enum SectionType {
        case hz
        case picture
        case selector
        case unknown
    }
    
    struct SectionData: DetailViewModel {
        var text: String?
        var imageURL: String?
        var selectedId: Int?
        var variants: [Variant]?
    }
    
    var name: String
    
    var sectionData: SectionData
    
    var sectionType: SectionType {
        
        switch self.name {
        case "hz":
            return .hz
        case "picture":
            return .picture
        case "selector":
            return .selector
        default:
            return .unknown
        }
    }
    
    init (resourceData: ResourceData) {
        
        self.name = resourceData.name
        self.sectionData = SectionData(text: resourceData.data.text,
                                       imageURL: resourceData.data.url,
                                       selectedId: resourceData.data.selectedId,
                                       variants: resourceData.data.variants)
        
    }
    
}
