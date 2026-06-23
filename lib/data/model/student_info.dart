/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;

@immutable
class StudentPhoto {
  const StudentPhoto({required this.bytes, this.mimeType});

  final Uint8List bytes;
  final String? mimeType;

  bool get isNotEmpty => bytes.isNotEmpty;
}

@immutable
class StudentInfo {
  const StudentInfo({
    required this.basic,
    required this.enrollment,
    required this.household,
    required this.preschool,
    required this.family,
    required this.contact,
    required this.other,
  });

  final BasicInfo basic;
  final EnrollmentInfo enrollment;
  final HouseholdInfo household;
  final PreschoolInfo preschool;
  final List<FamilyMember> family;
  final ContactInfo contact;
  final OtherInfo other;

  factory StudentInfo.fromHtml(String html) {
    final document = html_parser.parse(html);

    BasicInfo? basic;
    EnrollmentInfo? enrollment;
    HouseholdInfo? household;
    PreschoolInfo? preschool;
    ContactInfo? contact;
    OtherInfo? other;
    final family = <FamilyMember>[];

    final sections = document.querySelectorAll('.sub-info-wrap');
    for (final section in sections) {
      final title = section.querySelector('.box-title')?.text.trim() ?? '';
      if (title == '基本信息') {
        basic = _parseBasicInfo(section);
      } else if (title == '学籍信息') {
        enrollment = _parseEnrollmentInfo(section);
      } else if (title == '户籍档案') {
        household = _parseHouseholdInfo(section);
      } else if (title == '学前信息') {
        preschool = _parsePreschoolInfo(section);
      } else if (title == '家庭信息') {
        family.addAll(_parseFamilyInfo(section));
      } else if (title == '联系方式') {
        contact = _parseContactInfo(section);
      } else if (title == '其他信息') {
        other = _parseOtherInfo(section);
      }
    }

    return StudentInfo(
      basic: basic ?? const BasicInfo(),
      enrollment: enrollment ?? const EnrollmentInfo(),
      household: household ?? const HouseholdInfo(),
      preschool: preschool ?? const PreschoolInfo(),
      family: family,
      contact: contact ?? const ContactInfo(),
      other: other ?? const OtherInfo(),
    );
  }

  static String? _extractValue(dynamic section, String labelPrefix) {
    final items = section.querySelectorAll('.form-item');
    for (final item in items) {
      if (item.classes.contains('photo-item')) continue;
      final labelEl = item.querySelector('.item-label label');
      final valueEl = item.querySelector('.item-content label');
      if (labelEl == null || valueEl == null) continue;
      final label = labelEl.text.trim();
      if (label.startsWith(labelPrefix)) {
        final value = valueEl.text.trim();
        if (value == '★★★★' || value.isEmpty) return null;
        return value;
      }
    }
    return null;
  }

  static BasicInfo _parseBasicInfo(dynamic section) {
    return BasicInfo(
      studentId: _extractValue(section, '学号:'),
      name: _extractValue(section, '姓名:'),
      formerName: _extractValue(section, '曾用名:'),
      gender: _extractValue(section, '性别:'),
      pinyin: _extractValue(section, '姓名拼音:'),
      ethnicity: _extractValue(section, '民族:'),
      politicalStatus: _extractValue(section, '政治面貌:'),
      idType: _extractValue(section, '身份证件类型:'),
      idNumber: _extractValue(section, '身份证件号:'),
      examCandidateType: _extractValue(section, '考生类别:'),
      examCandidateNumber: _extractValue(section, '考生号:'),
      enrollmentDate: _extractValue(section, '入学日期:'),
      birthDate: _extractValue(section, '出生日期:'),
      remark: _extractValue(section, '备注:'),
      englishName: _extractValue(section, '英文名:'),
      expectedGraduation: _extractValue(section, '预计毕业日期:'),
    );
  }

  static EnrollmentInfo _parseEnrollmentInfo(dynamic section) {
    return EnrollmentInfo(
      grade: _extractValue(section, '所在年级:'),
      college: _extractValue(section, '院系信息:'),
      major: _extractValue(section, '专业信息:'),
      majorDirection: _extractValue(section, '专业方向:'),
      className: _extractValue(section, '班级信息:'),
      duration: _extractValue(section, '学制:'),
      educationLevel: _extractValue(section, '培养层次:'),
      registrationStatus: _extractValue(section, '学籍状态:'),
      currentStatus: _extractValue(section, '当前状态:'),
      isOnCampus: _extractValue(section, '是否在校:'),
      studentCategory: _extractValue(section, '学生类别:'),
      degree: _extractValue(section, '学位:'),
      cultivationMode: _extractValue(section, '培养方式:'),
      studyMode: _extractValue(section, '就读方式:'),
      counselor: _extractValue(section, '辅导员:'),
      counselorPhone: _extractValue(section, '辅导员联系方式:'),
      classTeacher: _extractValue(section, '班主任:'),
      classTeacherPhone: _extractValue(section, '班主任联系方式:'),
    );
  }

  static HouseholdInfo _parseHouseholdInfo(dynamic section) {
    return HouseholdInfo(
      birthplace: _extractValue(section, '出生地:'),
      nativePlace: _extractValue(section, '籍贯:'),
      residence: _extractValue(section, '户籍所在地:'),
      religion: _extractValue(section, '宗教信仰:'),
      bloodType: _extractValue(section, '血型:'),
      maritalStatus: _extractValue(section, '婚姻状况:'),
      health: _extractValue(section, '健康状况:'),
      onlyChild: _extractValue(section, '是否独生子女:'),
      nationality: _extractValue(section, '国籍:'),
      hasPassport: _extractValue(section, '有无护照:'),
      passportNumber: _extractValue(section, '护照号码:'),
      policeStation: _extractValue(section, '所属派出所:'),
    );
  }

  static PreschoolInfo _parsePreschoolInfo(dynamic section) {
    return PreschoolInfo(
      sourceProvince: _extractValue(section, '生源省:'),
      sourceCity: _extractValue(section, '生源市:'),
      sourceCategory: _extractValue(section, '生源类别:'),
      gaokaoScore: _extractValue(section, '高考成绩:'),
      gaokaoEnglish: _extractValue(section, '高考外语成绩:'),
      highSchool: _extractValue(section, '毕业中学:'),
      admittedMajor: _extractValue(section, '录取专业:'),
      admissionMethod: _extractValue(section, '录取方式:'),
      gaokaoSubject: _extractValue(section, '高考外语语种:'),
    );
  }

  static List<FamilyMember> _parseFamilyInfo(dynamic section) {
    final members = <FamilyMember>[];
    final parentsBlocks = section.querySelectorAll('.parents-info');
    for (final block in parentsBlocks) {
      members.add(
        FamilyMember(
          title: _extractValue(block, '称谓')?.replaceAll(RegExp(r'\d+:?'), ''),
          name: _extractValue(block, '姓名') ?? _extractValue(block, '父母/监护人姓名'),
          idType: _extractValue(block, '证件类型'),
          idNumber: _extractValue(block, '证件号码'),
          workplace: _extractValue(block, '工作单位'),
          phone: _extractValue(block, '联系方式'),
          age: _extractValue(block, '年龄'),
          politicalStatus: _extractValue(block, '政治面貌'),
        ),
      );
    }
    return members.where((m) => m.name != null || m.title != null).toList();
  }

  static ContactInfo _parseContactInfo(dynamic section) {
    return ContactInfo(
      phone: _extractValue(section, '联系电话:'),
      email: _extractValue(section, 'EMAIL:'),
      qq: _extractValue(section, 'QQ:'),
      wechat: _extractValue(section, '微信:'),
      familyContact: _extractValue(section, '家庭联系人:'),
      familyPhone: _extractValue(section, '家庭电话:'),
      familyAddress: _extractValue(section, '家庭详细地址:'),
    );
  }

  static OtherInfo _parseOtherInfo(dynamic section) {
    return OtherInfo(gaokaoLanguage: _extractValue(section, '高考外语语种:'));
  }
}

@immutable
class BasicInfo {
  const BasicInfo({
    this.studentId,
    this.name,
    this.formerName,
    this.gender,
    this.pinyin,
    this.ethnicity,
    this.politicalStatus,
    this.idType,
    this.idNumber,
    this.examCandidateType,
    this.examCandidateNumber,
    this.enrollmentDate,
    this.birthDate,
    this.remark,
    this.englishName,
    this.expectedGraduation,
  });

  final String? studentId;
  final String? name;
  final String? formerName;
  final String? gender;
  final String? pinyin;
  final String? ethnicity;
  final String? politicalStatus;
  final String? idType;
  final String? idNumber;
  final String? examCandidateType;
  final String? examCandidateNumber;
  final String? enrollmentDate;
  final String? birthDate;
  final String? remark;
  final String? englishName;
  final String? expectedGraduation;

  Map<String, String> get displayFields => _nonNull({
    '学号': studentId,
    '姓名': name,
    '曾用名': formerName,
    '性别': gender,
    '姓名拼音': pinyin,
    '民族': ethnicity,
    '政治面貌': politicalStatus,
    '身份证件类型': idType,
    '身份证件号': idNumber,
    '考生类别': examCandidateType,
    '考生号': examCandidateNumber,
    '入学日期': enrollmentDate,
    '出生日期': birthDate,
    '英文名': englishName,
    '备注': remark,
    '预计毕业日期': expectedGraduation,
  });
}

@immutable
class EnrollmentInfo {
  const EnrollmentInfo({
    this.grade,
    this.college,
    this.major,
    this.majorDirection,
    this.className,
    this.duration,
    this.educationLevel,
    this.registrationStatus,
    this.currentStatus,
    this.isOnCampus,
    this.studentCategory,
    this.degree,
    this.cultivationMode,
    this.studyMode,
    this.counselor,
    this.counselorPhone,
    this.classTeacher,
    this.classTeacherPhone,
  });

  final String? grade;
  final String? college;
  final String? major;
  final String? majorDirection;
  final String? className;
  final String? duration;
  final String? educationLevel;
  final String? registrationStatus;
  final String? currentStatus;
  final String? isOnCampus;
  final String? studentCategory;
  final String? degree;
  final String? cultivationMode;
  final String? studyMode;
  final String? counselor;
  final String? counselorPhone;
  final String? classTeacher;
  final String? classTeacherPhone;

  Map<String, String> get displayFields => _nonNull({
    '所在年级': grade,
    '院系': college,
    '专业': major,
    '专业方向': majorDirection,
    '班级': className,
    '学制': duration,
    '培养层次': educationLevel,
    '学籍状态': registrationStatus,
    '当前状态': currentStatus,
    '是否在校': isOnCampus,
    '学生类别': studentCategory,
    '学位': degree,
    '培养方式': cultivationMode,
    '就读方式': studyMode,
    '辅导员': counselor,
    '辅导员联系方式': counselorPhone,
    '班主任': classTeacher,
    '班主任联系方式': classTeacherPhone,
  });
}

@immutable
class HouseholdInfo {
  const HouseholdInfo({
    this.birthplace,
    this.nativePlace,
    this.residence,
    this.religion,
    this.bloodType,
    this.maritalStatus,
    this.health,
    this.onlyChild,
    this.nationality,
    this.hasPassport,
    this.passportNumber,
    this.policeStation,
  });

  final String? birthplace;
  final String? nativePlace;
  final String? residence;
  final String? religion;
  final String? bloodType;
  final String? maritalStatus;
  final String? health;
  final String? onlyChild;
  final String? nationality;
  final String? hasPassport;
  final String? passportNumber;
  final String? policeStation;

  Map<String, String> get displayFields => _nonNull({
    '出生地': birthplace,
    '籍贯': nativePlace,
    '户籍所在地': residence,
    '所属派出所': policeStation,
  });
}

@immutable
class PreschoolInfo {
  const PreschoolInfo({
    this.sourceProvince,
    this.sourceCity,
    this.sourceCategory,
    this.gaokaoScore,
    this.gaokaoEnglish,
    this.highSchool,
    this.admittedMajor,
    this.admissionMethod,
    this.gaokaoSubject,
  });

  final String? sourceProvince;
  final String? sourceCity;
  final String? sourceCategory;
  final String? gaokaoScore;
  final String? gaokaoEnglish;
  final String? highSchool;
  final String? admittedMajor;
  final String? admissionMethod;
  final String? gaokaoSubject;

  Map<String, String> get displayFields => _nonNull({
    '生源省': sourceProvince,
    '生源市': sourceCity,
    '毕业中学': highSchool,
    '录取专业': admittedMajor,
    '录取方式': admissionMethod,
    '高考外语语种': gaokaoSubject,
  });
}

@immutable
class FamilyMember {
  const FamilyMember({
    this.title,
    this.name,
    this.idType,
    this.idNumber,
    this.workplace,
    this.phone,
    this.age,
    this.politicalStatus,
  });

  final String? title;
  final String? name;
  final String? idType;
  final String? idNumber;
  final String? workplace;
  final String? phone;
  final String? age;
  final String? politicalStatus;

  Map<String, String> get displayFields => _nonNull({
    '称谓': title,
    '姓名': name,
    '证件类型': idType,
    '证件号码': idNumber,
    '工作单位': workplace,
    '联系方式': phone,
    '年龄': age,
    '政治面貌': politicalStatus,
  });
}

@immutable
class ContactInfo {
  const ContactInfo({
    this.phone,
    this.email,
    this.qq,
    this.wechat,
    this.familyContact,
    this.familyPhone,
    this.familyAddress,
  });

  final String? phone;
  final String? email;
  final String? qq;
  final String? wechat;
  final String? familyContact;
  final String? familyPhone;
  final String? familyAddress;

  Map<String, String> get displayFields => _nonNull({
    '联系电话': phone,
    'EMAIL': email,
    'QQ': qq,
    '微信': wechat,
    '家庭联系人': familyContact,
    '家庭电话': familyPhone,
    '家庭地址': familyAddress,
  });
}

@immutable
class OtherInfo {
  const OtherInfo({this.gaokaoLanguage});

  final String? gaokaoLanguage;
}

Map<String, String> _nonNull(Map<String, String?> map) {
  final result = <String, String>{};
  for (final entry in map.entries) {
    if (entry.value != null && entry.value!.isNotEmpty) {
      result[entry.key] = entry.value!;
    }
  }
  return result;
}
