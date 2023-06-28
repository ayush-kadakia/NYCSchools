//
//  HighSchoolInfoViewController.swift
//  NYCSchools
//
//  Created by Ayush Kadakia on 6/28/23.
//

import UIKit
import MapKit

class HighSchoolInfoViewController: UIViewController {

    ///stack view to hold all the labels + map
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false

        return map
    }()
    
    private let math: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let overview: PaddingLabel = {
       let label = PaddingLabel()
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let schoolName: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let reading: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    
    private let writing: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .gray
        return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(map)
        stackView.addArrangedSubview(schoolName)
        stackView.addArrangedSubview(math)
        stackView.addArrangedSubview(reading)
        stackView.addArrangedSubview(writing)
        stackView.addArrangedSubview(overview)

        
        let safeArea = view.safeAreaLayoutGuide
        ///i prefer to do my constraints programitcally, rather than using storyboard
        NSLayoutConstraint.activate([
            map.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            map.heightAnchor.constraint(equalToConstant: 200),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -16),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

        ])
    }
    
    public func configure(with school: NYCHighSchool) {
        ///populates the labels and map in the sheet with all the info
        schoolName.text = school.school_name
        overview.text = school.overview_paragraph
        math.text = "Math Average: \(school.sat?.sat_math_avg_score ?? "")"
        reading.text = "Reading Average: \(school.sat?.sat_critical_reading_avg_score ?? "")"
        writing.text = "Writing Average: \(school.sat?.sat_writing_avg_score ?? "")"
                
        ///map location setting
        let location = CLLocationCoordinate2DMake(Double(school.latitude!)!, Double(school.longitude!)!)
        let highSchoolAnnotation = MKPointAnnotation()
        highSchoolAnnotation.coordinate = location
        self.map.addAnnotation(highSchoolAnnotation)
        
        ///region setting
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: highSchoolAnnotation.coordinate, span: span)
        let adjustRegion = self.map.regionThatFits(region)
        self.map.setRegion(adjustRegion, animated:true)

    }
    

}

// UILabels don't have padding built in, so this small subclass will add it, this is mainly for aesthetic purposes
@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 10.0
    @IBInspectable var rightInset: CGFloat = 10.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
