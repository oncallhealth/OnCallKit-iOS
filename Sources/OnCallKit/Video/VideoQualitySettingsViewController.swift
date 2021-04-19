////
////  VidyoQualitySettingsViewController.swift
////  OnCall Health
////
////  Created by Domenic Bianchi on 2020-09-14.
////  Copyright © 2020 OnCall Health. All rights reserved.
////
//
//import UIKit
//
//protocol VidyoQualitySettingsViewControllerDelegate: AnyObject {
//    func didUpdateVideoSettings(videoQuality: OCVidyoConnector.VideoQuality)
//}
//
//// MARK: - VidyoQualitySettingsViewController
//
//class VidyoQualitySettingsViewController: SheetViewController {
//
//    // MARK: Lifecycle
//
//    init(viewModel: VidyoQualitySettingsViewModel) {
//        self.viewModel = viewModel
//        super.init(viewModel: viewModel)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: Internal
//
//    weak var videoQualityDelegate: VidyoQualitySettingsViewControllerDelegate?
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let rowType = OCVidyoConnector.VideoQuality(rawValue: indexPath.row),
//              let cell = tableView.dequeueReusableCell(
//                withIdentifier: ComponentType.textIconRow.rawValue,
//                for: indexPath) as? TextIconRow else
//        {
//            return UITableViewCell()
//        }
//
//        switch rowType {
//        case .low:
//            cell.configure(
//                text: "low".localized(),
//                icon: viewModel.selectedQuality == .low ? "ic-solid-check" : "",
//                tintColor: viewModel.selectedQuality == .low ? .primary : nil)
//        case .medium:
//            cell.configure(
//                text: "medium".localized(),
//                icon: viewModel.selectedQuality == .medium ? "ic-solid-check" : "",
//                tintColor: viewModel.selectedQuality == .medium ? .primary : nil)
//        case .high:
//            cell.configure(
//                text: "high".localized(),
//                icon: viewModel.selectedQuality == .high ? "ic-solid-check" : "",
//                tintColor: viewModel.selectedQuality == .high ? .primary : nil)
//        }
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let selectedQuality = OCVidyoConnector.VideoQuality(rawValue: indexPath.row) {
//            videoQualityDelegate?.didUpdateVideoSettings(videoQuality: selectedQuality)
//            dismiss(animated: true)
//        }
//    }
//
//    // MARK: Private
//
//    private let viewModel: VidyoQualitySettingsViewModel
//}
