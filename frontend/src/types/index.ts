export enum Role {
  CITIZEN = 'CITIZEN',
  MAYOR = 'MAYOR',
  MINISTER = 'MINISTER',
  PM = 'PM',
  ADMIN = 'ADMIN'
}

export enum TaskStatus {
  PENDING_APPROVAL = 'PENDING_APPROVAL',
  ACTIVE = 'ACTIVE',
  AWAITING_REVIEW = 'AWAITING_REVIEW',
  COMPLETED = 'COMPLETED'
}

export interface User {
  id: string;
  username: string;
  email: string;
  role: string;
  socialScore: number;
  createdAt: string;
  room: Room | null;
  assignedTasks: any[];
  /** Computed office flags (from department/room assignments) */
  isPrimeMinister: boolean;
  isForeignMinister: boolean;
  isMayor: boolean;
}

export interface Department {
  id: string;
  name: string;
  primeMinisterId?: string | null;
  foreignMinisterId?: string | null;
  primeMinister?: { id: string; username: string; email: string } | null;
  foreignMinister?: { id: string; username: string; email: string } | null;
}

export interface DepartmentListItem {
  id: string;
  name: string;
  primeMinister: { id: string; username: string; email: string } | null;
  foreignMinister: { id: string; username: string; email: string } | null;
  rooms: Array<{
    id: string;
    roomNumber: string;
    users: Array<{ id: string; username: string; email: string; role: string }>;
  }>;
}

export interface RoomUser {
  id: string;
  username: string;
  role: string;
}

export interface Room {
  id: string;
  roomNumber: string;
  department: Department;
  mayor: RoomUser | null;
  users: RoomUser[];
}

export interface Task {
  id: string;
  title: string;
  description?: string;
  status: TaskStatus;
  roomId: string;
  createdById: string;
  assignedToId?: string;
  completionSummary?: string;
  completedAt?: string;
  mayorReviewNote?: string;
  reviewedAt?: string;
  createdAt: string;
  updatedAt: string;
  createdBy?: User;
  assignedTo?: User;
}

export interface UserProfile {
  user: User;
  room?: {
    id: string;
    roomNumber: string;
    department: Department;
    mayor: User | null;
    users: User[];
  };
  assignedTasks: Task[];
}

export interface CreateTaskDto {
  title: string;
  description?: string;
}

export interface ApproveAssignTaskDto {
  assignedToId: string;
}

export interface CompleteTaskDto {
  completionSummary: string;
}

export interface ReviewTaskDto {
  accept: boolean;
  note?: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

export interface SignupDto {
  username: string;
  email: string;
  password: string;
  departmentName: string;
  roomNumber: string;
}

export interface AuthResponse {
  accessToken: string;
}

export enum ViolationStatusEnum {
  ACTIVE = 'ACTIVE',
  APPEALED = 'APPEALED',
  IN_EVALUATION = 'IN_EVALUATION',
  CLOSED_UPHELD = 'CLOSED_UPHELD',
  CLOSED_OVERTURNED = 'CLOSED_OVERTURNED',
  EXPIRED = 'EXPIRED',
}

export enum ViolationVerdictEnum {
  UPHELD = 'UPHELD',
  OVERTURNED = 'OVERTURNED',
  PUNISH_MAYOR = 'PUNISH_MAYOR',
}

export interface Violation {
  id: string;
  status: ViolationStatusEnum;
  roomId: string;
  title: string;
  description?: string;
  points: number;
  expiresAt?: string | null;
  archivedAt?: string | null;
  pointsRefunded: number;
  refundedAt?: string | null;
  appealedAt?: string | null;
  appealNote?: string | null;
  evaluationStartedAt?: string | null;
  evaluationClosedAt?: string | null;
  verdict?: ViolationVerdictEnum | null;
  verdictNote?: string | null;
  closedById?: string | null;
  mayorViolationId?: string | null;
  offender: { id: string; username: string };
  createdBy: { id: string; username: string };
  chatRoom?: { id: string; closedAt?: string | null } | null;
  createdAt: string;
}

export interface CreateViolationPayload {
  offenderId: string;
  title: string;
  description?: string;
  points: number;
  expiresAt?: string;
}

export interface CloseEvaluationPayload {
  verdict: ViolationVerdictEnum;
  verdictNote?: string;
  mayorPenaltyPoints?: number;
  mayorPenaltyTitle?: string;
}

export interface CaseChatMessage {
  id: string;
  content: string;
  createdAt: string;
  chatRoomId?: string;
  sender: { id: string; username: string; role: string };
}

export interface CaseChatMember {
  id: string;
  userId: string;
  user: { id: string; username: string; role: string };
  joinedAt: string;
}