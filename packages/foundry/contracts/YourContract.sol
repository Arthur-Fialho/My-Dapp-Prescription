// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YourContract {
    error OnlyDoctorCanPrescribe();
    error PrescriptionAlreadyFilled();
    error expirationTimeNotPassedYet();

    address doctor;
    address owner;
    uint256 prescriptionDate;
    uint256 prescriptionId;

    // Mapeamento de endereços de pacientes para receitas
    mapping(address => Prescription[]) public prescriptions;
    mapping(uint256 => address) public patientAdrress;
    uint256[] public prescriptionIdArray;

    // Estrutura para representar uma receita médica
    struct Prescription {
        address doctor; // Endereço do médico que prescreveu a receita
        address patient; // Endereço do paciente para quem a receita foi prescrita
        string[] medication; // Medicamento prescrito
        uint256[] quantity; // Quantidade do medicamento
        bool isFilled; // Flag para indicar se a receita foi preenchida pela farmácia
        uint256 expirationTime; // Tempo para expiração da receita
        uint256 prescriptionId;
    }

    // Evento para registrar quando uma nova receita é prescrita
    event PrescriptionCreated(
        address doctor,
        address patient,
        string[] medication,
        uint256[] quantity,
        uint256 expirationTime,
        uint256 prescriptionId
    );

    modifier OnlyDoctor() {
        if (msg.sender != address(doctor)) {
            revert OnlyDoctorCanPrescribe();
        }
        _;
    }

    constructor(address _owner) {
        owner = _owner;
        doctor = msg.sender;
    }

    // Função para prescrever uma nova receita
    function prescribeMedication(
        address _patient,
        string[] memory _medication,
        uint256[] memory _quantity,
        uint256 _expirationTime
    ) public OnlyDoctor {
        // Cria uma nova receita
        Prescription memory newPrescription = Prescription({
            doctor: msg.sender,
            patient: _patient,
            medication: _medication,
            quantity: _quantity,
            isFilled: false,
            expirationTime: block.timestamp + _expirationTime,
            prescriptionId: prescriptionId
        });
        prescriptionDate = block.timestamp;

        // Adiciona a receita ao mapeamento de receitas do paciente
        prescriptions[_patient].push(newPrescription);
        prescriptionIdArray.push(_expirationTime + prescriptionDate);
        prescriptionId++;

        // Emite o evento de criação de receita
        emit PrescriptionCreated(
            msg.sender,
            _patient,
            _medication,
            _quantity,
            _expirationTime,
            prescriptionId
        );
    }

    function expirationTimeExecuter(
        address _patient,
        uint256 _prescriptionIndex
    ) public {
        Prescription storage prescription =
            prescriptions[_patient][_prescriptionIndex];

        if (prescription.isFilled) {
            revert PrescriptionAlreadyFilled();
        }

        if (prescription.expirationTime < block.timestamp) {
            prescription.isFilled = true;
        } else {
            revert expirationTimeNotPassedYet();
        }
    }

    function expirationTimeRunner() public view {
        for (uint256 i = 0; i < prescriptionIdArray.length; i++) {
            if (prescriptionIdArray[i] < block.timestamp) {}
        }
    }
    // function getPatientAddress() public view returns(address){
    //     for(uint256 i = 0; i < prescriptionIdArray.length; i ++){
    //         _patientAddress = patientAdrress[i]
    //     }
    //     return _patientAddress;
    // }

    // TODO

    // Função para marcar uma receita como preenchida pela farmácia
    function fillPrescription(
        address _patient,
        uint256 _prescriptionIndex
    ) public {
        // Garante que apenas farmácias possam marcar receitas como preenchidas

        // TODO Criar um modifier para OnlyPharmacy
        // require(msg.sender == pharmacy, "Only pharmacies can fill prescriptions");

        // Obtém a receita do paciente
        Prescription storage prescription =
            prescriptions[_patient][_prescriptionIndex];

        // Garante que a receita ainda não foi preenchida
        if (prescription.isFilled) {
            revert PrescriptionAlreadyFilled();
        }

        // Marca a receita como preenchida
        prescription.isFilled = true;
    }
}
