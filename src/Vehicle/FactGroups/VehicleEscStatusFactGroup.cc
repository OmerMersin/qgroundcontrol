#include "VehicleEscStatusFactGroup.h"
#include "Vehicle.h"

VehicleEscStatusFactGroup::VehicleEscStatusFactGroup(QObject* parent)
    : FactGroup                         (1000, ":/json/Vehicle/EscStatusFactGroup.json", parent)
    , _indexFact                        (0, _indexFactName,                         FactMetaData::valueTypeUint8)

    , _rpmFirstFact                     (0, _rpmFirstFactName,                      FactMetaData::valueTypeFloat)
    , _rpmSecondFact                    (0, _rpmSecondFactName,                     FactMetaData::valueTypeFloat)
    , _rpmThirdFact                     (0, _rpmThirdFactName,                      FactMetaData::valueTypeFloat)
    , _rpmFourthFact                    (0, _rpmFourthFactName,                     FactMetaData::valueTypeFloat)

    , _currentFirstFact                 (0, _currentFirstFactName,                  FactMetaData::valueTypeFloat)
    , _currentSecondFact                (0, _currentSecondFactName,                 FactMetaData::valueTypeFloat)
    , _currentThirdFact                 (0, _currentThirdFactName,                  FactMetaData::valueTypeFloat)
    , _currentFourthFact                (0, _currentFourthFactName,                 FactMetaData::valueTypeFloat)

    , _voltageFirstFact                 (0, _voltageFirstFactName,                  FactMetaData::valueTypeFloat)
    , _voltageSecondFact                (0, _voltageSecondFactName,                 FactMetaData::valueTypeFloat)
    , _voltageThirdFact                 (0, _voltageThirdFactName,                  FactMetaData::valueTypeFloat)
    , _voltageFourthFact                (0, _voltageFourthFactName,                 FactMetaData::valueTypeFloat)

    , _temperature1Fact                 (0, _temperature1FactName,                  FactMetaData::valueTypeFloat)
    , _temperature2Fact                 (0, _temperature2FactName,                  FactMetaData::valueTypeFloat)
    , _temperature3Fact                 (0, _temperature3FactName,                  FactMetaData::valueTypeFloat)
    , _temperature4Fact                 (0, _temperature4FactName,                  FactMetaData::valueTypeFloat)
{
    _addFact(&_indexFact,                       _indexFactName);

    _addFact(&_rpmFirstFact,                    _rpmFirstFactName);
    _addFact(&_rpmSecondFact,                   _rpmSecondFactName);
    _addFact(&_rpmThirdFact,                    _rpmThirdFactName);
    _addFact(&_rpmFourthFact,                   _rpmFourthFactName);

    _addFact(&_currentFirstFact,                _currentFirstFactName);
    _addFact(&_currentSecondFact,               _currentSecondFactName);
    _addFact(&_currentThirdFact,                _currentThirdFactName);
    _addFact(&_currentFourthFact,               _currentFourthFactName);

    _addFact(&_voltageFirstFact,                _voltageFirstFactName);
    _addFact(&_voltageSecondFact,               _voltageSecondFactName);
    _addFact(&_voltageThirdFact,                _voltageThirdFactName);
    _addFact(&_voltageFourthFact,               _voltageFourthFactName);

    _addFact(&_temperature1Fact,                _temperature1FactName);
    _addFact(&_temperature2Fact,                _temperature2FactName);
    _addFact(&_temperature3Fact,                _temperature3FactName);
    _addFact(&_temperature4Fact,                _temperature4FactName);
}

void VehicleEscStatusFactGroup::handleMessage(Vehicle* /* vehicle */, mavlink_message_t& message)
{
    if (message.msgid != MAVLINK_MSG_ID_ESC_STATUS) {
        return;
    }

    mavlink_esc_status_t content;
    mavlink_msg_esc_status_decode(&message, &content);

    // Update facts with received data
    _indexFact.setRawValue                        (content.index);

    _rpmFirstFact.setRawValue                     (content.rpm[0]);
    _rpmSecondFact.setRawValue                    (content.rpm[1]);
    _rpmThirdFact.setRawValue                     (content.rpm[2]);
    _rpmFourthFact.setRawValue                    (content.rpm[3]);

    _currentFirstFact.setRawValue                 (content.current[0]);
    _currentSecondFact.setRawValue                (content.current[1]);
    _currentThirdFact.setRawValue                 (content.current[2]);
    _currentFourthFact.setRawValue                (content.current[3]);

    _voltageFirstFact.setRawValue                 (content.voltage[0]);
    _voltageSecondFact.setRawValue                (content.voltage[1]);
    _voltageThirdFact.setRawValue                 (content.voltage[2]);
    _voltageFourthFact.setRawValue                (content.voltage[3]);

    _temperature1Fact.setRawValue                 (content.temperature[0]);
    _temperature2Fact.setRawValue                 (content.temperature[1]);
    _temperature3Fact.setRawValue                 (content.temperature[2]);
    _temperature4Fact.setRawValue                 (content.temperature[3]);
}
